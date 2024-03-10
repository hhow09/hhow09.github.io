---
title: LSM Tree
description: LSM Tree
date: 2024-02-10
tags:
  - database
  - system design
layout: layouts/post.njk
---

## LSM Tree
{% image "./lsm-tree.png", "LSM Tree Structure" %}

1. is designed to reduce disk I/O (bottleneck) with **memory-buffered writes**
2. consisted of in-memory part (memtable) + disk part (SSTable)
3. The term **merge** refers to the algorithm with which data is managed in the structure. [^2]
4. The term **tree** in its name comes from the fact that data is organized into multiple levels similar to devices in the storage hierarchy in a typical computer where the top level device holds smaller subset of data and is faster to access while the lower levels holds larger segments of data and is slow to access. [^2]

## Key Features [^3]
1. **In-memory buffering**. Incoming writes are first stored in an in-memory structure, the memtable, to enable fast write operations and quick access.
2. **Batched writes**. LSM trees accumulate writes in memory, batching them before flushing to disk to minimize the number of disk writes, improving efficiency.
3. **Reduced overwrites**. By buffering writes in memory LSM trees reduce the number of random disk writes, enhancing performance.
4. **Compaction**. Periodic compaction optimizes storage by merging and organizing data, reducing fragmentation and enhancing write performance.
5. **Multi-level search.** Multi-level search and increasingly sorted data structures improves read efficiency. Compaction enhances read performance, reducing disk reads and improving data organization.
6. **Adaptability**. Log-structured merge trees adapt well to varying workloads, efficiently handling **write-heavy operations** without sacrificing read efficiency.
7. **Sparse Index** in each SSTable: Instead of maintain a large index in memory, we can maintain the index in each SSTable file.

## Components
### 1. Memtable
- LSMTree starts with an **in-memory balanced tree** (or hash table).
    - What data structure of Memtable typically depends upon the performance requirements but must have a property that it should provide a sorted iteration over its contents. [^2]
- it keeps the latest data.
- When the memtable gets bigger than some threshold (typically a few megabytes) write it out to disk as an SSTable file. This can be done efficiently because the tree already maintains the key-value pairs sorted by key. [^4]

### 2. SSTable (in disk)
- SSTable is the disk component for LSM-tree.
- An SSTable provides a persistent, ordered immutable map from keys to values, where both keys and values are arbitrary **byte strings**. [^1]
- Operations are provided to look up the value associated with a specified key, and to iterate over all key/value pairs in a specified key range. [^1]

### Example: File Layout of SSTable in Cassandra [^6]
> A single SSTable is made of multiple files, called components. These components are generally specific to the SSTable format.
```
nb-1-big-Data.db
nb-1-big-Index.db
nb-1-big-Summary.db             
nb-1-big-CompressionInfo.db 
nb-1-big-Digest.crc32
nb-1-big-Filter.db
nb-1-big-Statistics.db
nb-1-big-TOC.txt
```

### Index 
- Why: If all we do is combine and merge SSTables, our SSTables would get quite large soon at the lower levels. Reads from those files will have to iterate over many keys to find the requested key. A linear scan at worst at the lowest level SSTables.
- In practical implementations, SSTable files are also augmented with an index file which acts as a **first point of contact when reading data from an SSTable**. 

#### Lookup 
- A lookup can be performed with a single disk seek: [^1]
- the index is loaded into memory when the SSTable is opened.
- we first find the appropriate block by performing a binary search in the in-memory index, and then reading the appropriate block from disk.
- Optionally, an SSTable can be completely mapped into memory, which allows us to perform lookups and scans without touching disk. [^1]

### 3. WAL (write ahead log)
- for crash recovery
- before actually write to memtable, write first to WAL


## Write Process
1. When LSM Tree writes data, it first writes a record to [WAL](#3-wal-write-ahead-log) 
2. and then writes the data to MemTable in memory.
    - Add or Update: write value to the key
    - Delete: mark tombstone to the key (actual delele happens in [compaction](#compaction))
3. As the MemTable grows, it eventually reaches a size threshold. Once this threshold is crossed, the MemTable is considered full and needs to be flushed to disk as an SSTable.

## Read Process [^5]
Space amplification: given the write process, **data could appear in multiple SSTables**. We need to find the data from latest to oldest SSTables.

1. Lookup in memtable
2. If not found, Look up in Level 0 SSTable
3. If not found, keep look up in Level 1...N SSTable

check [SSTable: Lookup](#lookup) for details.


## Compaction
- Compaction is the process of merging multiple smaller SSTables into larger ones, which reduces the number of SSTables and the amount of disk space used by the data.
// TODO


## Read Optimizations
### 1. Bloom Filter
It helps determine if a particular key exists in the SSTables, reducing the number of disk reads when searching for data.

## References
[^1]: [Google Big Table](https://web.eecs.umich.edu/~manosk/assets/papers/bigtable.pdf)
[^2]: [What is a LSM Tree?](https://dev.to/creativcoder/what-is-a-lsm-tree-3d75)
[^3]: [scylladb: Log Structured Merge Tree](https://www.scylladb.com/glossary/log-structured-merge-tree/)
[^4]: Designing Data Intensive Applications. Chapter 3: Storage and Retrieval
[^5]: [Sobyte: Principle of LSM Tree](https://www.sobyte.net/post/2022-04/lsm-tree/)
[^6]: [Apache Cassandra 4.1: New SSTable Identifiers](https://cassandra.apache.org/_/blog/Apache-Cassandra-4.1-New-SSTable-Identifiers.html)