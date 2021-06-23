# Distributed Cache

The content is mainly based on [System Design Interview - Distributed Cache](https://youtu.be/iuqZvajTOyA).

## Table of Contents

- [Requirements](#requirements)
- [LRU Cache](#lru-cache)
- [Distributed](#distributed)
- [Hash](#hash)
- [Cache Client](#cache-client)
- [Data replication](#data-replication)
- [What Else Important](#what-else-important)
  - Potential Inconsistency
  - data expiration
  - local cache
  - security
  - monitoring and logging

## Requirements

### Functional

- put
- get

### Non-functional

- performance
- scalability
- availability
- durability

## LRU Cache

## Distributed

- cache host only store chunk of data, i.e. `shard`
- [cache client](#cache-client) library inside the service knows about all shards and forward request to a particular shard with `TCP` / `UDP`.

### Dedicated cache cluster

- cache host is **isolated** from service host.

- Pros: cache host can be used by multiple services.
- Pros: flexibility in choosing hardware.

### co-located cache

- we run cache as a **separate process on a host**.

- Pros: no extra hardware or operational cost
- Pros: scale together with service.

## Hash

> How do cache client decide which cache shard to call?

### MOD hashing

```
HashHostIdx = HashFunction(key) % NumberOfCacheHosts
```

- usually not feasible for production.
- Cons: When cache host `add` or `deleted`, high probability of cache misses because **all nodes are affected**.

### consistent Hashing

![](/img/system/2-distributed-cache/consistent-hash.png)

- Pros: When cache host `add` or `deleted`, only small subset (neighbors) of nodes are affected.

#### Domino Effect

- when one node dies the load may transferred to another node
- then cause another dies as well, causing chain reaction.

#### Uneven Distribution

- can solve with `Virtual Nodes`, `Jump Hash`, `Proportional Hashing`

##### Virtual NOdes

instead of positioning a single spot per node on ring, we can position **more than one spot per node**.

---

## Cache Client

- is: a `library`
- stores: list of cache hosts in sorted order.
- responsible for: cache host selection (can use **binary search**).

> How do we maintain the list of cache client ?

![](/img/system/2-distributed-cache/cache-client-list-maintain.png)

### Static server list

- store as a file
- Cons: `not flexible`, need to re-deploy when hosts change manually.

### Dynamic server list

- use configuration service (e.g. [ZooKeeper](https://zookeeper.apache.org/), [Redis Sentinel](https://redis.io/topics/sentinel))
- cache host sends heartbeat to the config service periodically.
- Pros: fully automate list maintenance

## Data replication

> How to achieve high availability in high QPS (hot shard)? Data replication

- we discuss `async` `leader-follower` data replication here.
- structure and implementation are based on [DDIA CH5: Replication - Leaders and Followers](https://github.com/hhow09/ddia-notes/tree/master/Ch5-Replication#leaders-and-followers)
- Put: only through leader
- Get: can through leader and follower
- Failover: can be implemented by `Cache Client`

## What Else Important

### Potential Inconsistency

- when partition appears, may get stale result from follower.
- when some cache nodes are down, some cache shards are not available.
- Discussion: tradeoff between sync and async replication.

### data expiration

1. `passively` expire cache on get request
2. maintenance thread runs regularly

### local cache

- can implemented local cache as well
- e.g. [Guava Cache](https://www.baeldung.com/guava-cache)

### security

- ensure only the approved client can access the cache
- may encrypt and decrypt cache when put and get cache.

### monitoring and logging

- number of faults while calling the cache
- latency
- number of hits and misses
- CPU and memory utilization on cache hosts
- network I/O

## Summary

![](/img/system/2-distributed-cache/distributed-cache-structure.png)

## Reference

- [System Design Interview - Distributed Cache](https://youtu.be/iuqZvajTOyA)
- [consistent hashing in Python](https://gist.github.com/reorx/8470123)
- [Consistent Hashing Algorithm: 應用情境、原理與實作範例](https://medium.com/@chyeh/consistent-hashing-algorithm-%E6%87%89%E7%94%A8%E6%83%85%E5%A2%83-%E5%8E%9F%E7%90%86%E8%88%87%E5%AF%A6%E4%BD%9C%E7%AF%84%E4%BE%8B-41fd16ad334a)
- [NoSQL Essentials: Cassandra](https://www.slideshare.net/frodriguezolivera/nosql-essentials-cassandra-15625311)
