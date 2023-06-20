---
title: System Design Interview Vol.2 - Chapter 6. Ad Click Event Aggregation
description: System Design Interview Vol.2 - Chapter 6. Ad Click Event Aggregation
date: 2023-06-18
tags:
  - distributed system
  - system design
layout: layouts/post.njk
---

the content mainly comes from [System Design Interview Vol.2](https://www.amazon.com/System-Design-Interview-Insiders-Guide/dp/1736049119) - [Chapter 6. Ad Click Event Aggregation](https://github.com/alex-xu-system/bytebytego/blob/main/system_design_links_vol2.md#chapter-6-ad-click-event-aggregation)

design a ad click event aggregation system for near-realtime data.

## TLDR
1. data pipeline / streaming: message queue
2. aggregation service: map reduce
3. database: read-heavy, write-heavy, no update or transaction reqiured
3. issues:
    - duplicate events
    - exactly once processing
    - fault tolerance
    - hotspot
4. scaling
    - horizontal scaling in message queue, database and aggregaiton service

## Requirement
### Functional Requirement
1. Support querying aggregated data: the number of clicks of certian ad (`ad_id`) in last `M` minutes
2. Support querying aggregated data: top `N` most clicked ad in last `M` minutes.
3. Support filtering by different attributes in above 2 querys.
4. Dataset volume is FAANG scale
    - volume: single database is not a choice.

### Non-Functional Requirement
1. correctness of the aggregation result is important
    - as data is used for RTB and ads billing
2. Properly handle delayed duplicate events
3. The system should be resilient to partial failures.
4. End-to-end latency should be a few minutes, at most.
    - need realtime streaming system (instead of batch system)
### Estimation
- active users: 1e9 / day
- assume event per user: 1 / user
- QPS: `(1e9 * 1) / (1e5) = 1e5`
    - assume peak hour could be `5e5`

## High Level Design
### Data Model
#### Raw Event
| ad_id        | timestamp           | user_id | ip            | country_code |
|--------------|---------------------|---------|---------------|--------------|
| ad001        | 2023-06-01 00:00:01 | user1   | 207.148.22.22 | US           |
| ad001        | 2023-06-01 00:00:02 | user2   | 209.153.55.11 | JP           |
| ad002        | 2023-06-01 00:00:02 | user2   | 209.153.55.11 | JP           |

#### Aggregated Data
| ad_id        | timestamp_minute | count | filter_id |
|--------------|------------------|-------|-----------|
| ad001        | 202306010000     | 5     | 0023      |
| ad001        | 202306010000     | 7     | 0012      |
| ad002        | 202306010001     | 7     | 0012      |
| ad002        | 202306010001     | 8     | 0023      |

data under same `ad_id-timestamp_minute` can be further group by `filter_id`

### Query API 
#### the number of clicks of certian ad (`ad_id`) in last `M` minutes
- API: `GET /v1/ads/{:ad_id}/aggregated_count`
- query parameters: 
    - `from_minute`
    - `to_minute`
    - `filter_id`
- returns `ad_id` and `count`

#### top `N` most clicked ad in last `M` minutes
- API: `GET /v1/ads/popular_ads`
- query parameters: 
    - `count`: top `N`
    - `window`: last `M` minutes
    - `filter_id`
- returns `ad_ids`

### Data Storage
we need to store both raw data and aggregated data

#### Comparison between querying raw data vs aggregated data

|       | query raw data                        | query aggregated data        |
|-------|---------------------------------------|------------------------------|
| usage | by other service                      | this system                  |
| pros  | full data set,  support ad-hoc filter | smaller data set, fast query |
| cons  | huge storage, slow query              | data loss                    |
| where  | cold storage                         | database                     |


#### Database Choice
##### analyze
- both read heavy and write-heavy
    - read: refresh the aggregation data in dashboard
    - write: insert the data
- no relation and transaction needed
- time series

##### Choices
- InfluxDB [[1]](#reference)
- Cassandra [[2]](#reference)
    - Netflix use cassandra for time series database [[3]](#reference)
    - storage engine: LSM tree [[4]](#reference) (good for write heavy)
- S3 + [Parquet](https://www.databricks.com/glossary/what-is-parquet)
    - columnar storage

### High Level Design
{% image "./high-level-design.svg", "Figure 3: High Level Design" %}

Kafka support high throughput, exact-once delivery.we can discuss exact-once delivery / atomic commit in [Delivery Guarantees](#delivery-guarantees)

### Aggregation Service
#### the number of clicks of certian ad (`ad_id`) in last `M` minutes
{% image "./aggregate-the-number-of-clicks.svg", "Figure 8 Aggregate the number of clicks" %}

## Deep Dive
### Aggregation Window and Watermark
#### What Is Watermarking?  
> when working with real-time streaming data there will be delays between event time and processing time due to how data is ingested and whether the overall application experiences issues like downtime. Due to these potential variable delays, the engine that you use to process this data needs to have some mechanism to decide when to close the aggregate windows and produce the aggregate result.
[[5]](#reference)

### Delivery Guarantees
In most circumstances, **at-least once** processing is good enough if a small percentage of duplicates are acceptable. However, this is not the case for our system. Differences of a few percent in data points could result in discrepancies of millions of dollars. 

Therefore, we recommend **exactly-once delivery** for the system.

### Data deduplication
two common sources: 

1. client resend
2. aggregation server outage

{% image "./duplicate-data.svg", "Figure 17 Duplicate data" %}

If step 6 fails, perhaps due to Aggregator outage, events from 100 to 110 are already sent to the downstream, but the new offset 110 is not persisted in upstream Kafka. In this case, a new Aggregator would consume again from offset 100, even if those events are already processed, causing duplicate data.

#### Solution
{% image "./distributed-transaction.svg", "Figure 20 Distributed transaction" %}

To achieve **exactly-once processing** [[6]](#reference), we need to put operations between step 4 to step 6 in one distributed transaction.
        
Most common technique is two phase commit

## Scale the system
### Scale the message queue
1. partition key: use `ad_id` as **partition key**[[7]](#reference) so that an aggregation service can subscribe to all events of the same `ad_id`.
2. number of partitions: if more consumers need to be added, try to do it during off-peak hours to minimize the impact.
3. Topic physical sharding: We can split the data by geography (`topic_north_america`, `topic_europe`, `topic_asia`, etc.,) or by business type (`topic_web_ads`, `topic_mobile_ads`, etc).
    - Pros: increased system throughput, reduced rebalance time.
    - Cons: extra complexity

### Scale the aggregation service
1. multi-threading: Allocate events with different `ad_id`s to different threads.

### Scale the database
Cassandra natively supports horizontal scaling,

### Hotspot issue
#### Aggregaion Service
some `ad_id` might receive many more ad click events than others.

Solution: dynamically allocate more node in aggregation service.

#### Kafka
The publisher specifies the topic and the partition of a message before publishing. Hence, it’s the publisher’s responsibility to ensure that the partition logic will not result in a hot partition.

[Confluent: Monitoring Kafka with JMX](https://docs.confluent.io/platform/current/kafka/monitoring.html)
### Fault tolerance

- aggregaion service works in memory and **could fail**
- Replaying data from the beginning of Kafka is slow.

Solution: snapshot aggregaion service to safe **current state** and **event offset**

{% image "./aggregation-node-failover.svg", "Figure 27 Aggregation node failover" %}

## Data monitoring and correctness
### Continuous monitoring
- Latency
- Message queue size
    - for aggregation servie to scale the node
    - for application to apply back pressure.
- System resources on aggregation nodes

### Reconciliation
- purpose: comparing different sets of data in order to ensure data integrity.
- how: using a **batch job** and reconciling with the real-time aggregation result.
- why: some events might arrive late, the result from the batch job might not match exactly with the real-time aggregation result.

{% image "./design-with-reconciliation.svg", "Figure 28 Final design" %}
## Reference
1. [InfluxDB Tops Cassandra in Time Series Data & Metrics Benchmark](https://www.influxdata.com/blog/influxdb-vs-cassandra-time-series/)
2. [Cassandra Time Series Data Modeling For Massive Scale](https://thelastpickle.com/blog/2017/08/02/time-series-data-modeling-massive-scale.html)
3. [Scaling Time Series Data Storage — Part I](https://netflixtechblog.com/scaling-time-series-data-storage-part-i-ec2b6d44ba39)
4. [Apache Cassandra™ 3.x - Storage engine](https://docs.datastax.com/en/cassandra-oss/3.x/cassandra/dml/dmlManageOndisk.html)
5. [Feature Deep Dive: Watermarking in Apache Spark Structured Streaming](https://www.databricks.com/blog/2022/08/22/feature-deep-dive-watermarking-apache-spark-structured-streaming.html)
6. [An Overview of End-to-End Exactly-Once Processing in Apache Flink (with Apache Kafka, too!)](https://flink.apache.org/2018/02/28/an-overview-of-end-to-end-exactly-once-processing-in-apache-flink-with-apache-kafka-too/)
7. [Streams and Tables in Apache Kafka: Topics, Partitions, and Storage Fundamentals](https://www.confluent.io/blog/kafka-streams-tables-part-2-topics-partitions-and-storage-fundamentals/#partition-events)