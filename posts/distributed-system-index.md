---
title: Distributed System Index
description: Distributed System Index
date: 2023-04-23
tags:
  - distributed system
layout: layouts/post.njk
---

## Course / Books
- [Designing Data Intensive Applications](https://www.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/)
- [MIT 6.824: Distributed Systems](https://pdos.csail.mit.edu/6.824/index.html)
- [CAM: Concurrent and Distributed Systems](https://www.cl.cam.ac.uk/teaching/2122/ConcDisSys/)
- [Distributed Systems lecture series: Martin Kleppmann](https://www.youtube.com/playlist?list=PLeKd45zvjcDFUEv_ohr_HdUFe97RItdiB)
    - [course notes](https://www.cl.cam.ac.uk/teaching/2122/ConcDisSys/dist-sys-notes.pdf)
- [Martin Fowler: Patterns of Distributed Systems](https://martinfowler.com/articles/patterns-of-distributed-systems/)

## CAP Theorem
- [henryr/cap-faq](https://github.com/henryr/cap-faq)

### Issues
- split brain

## Consistency Models
overview: [jepsen/consistency](https://jepsen.io/consistency)
### linearizability
### causal consistency
- [Clocks and Causality - Ordering Events in Distributed Systems](https://www.exhypothesi.com/clocks-and-causality/)
- [Jepsen: Causal Consistency](https://jepsen.io/consistency/models/causal)
- [Causal Consistency Guarantees – Case Studies](https://vkontech.com/causal-consistency-guarantees-case-studies/#What_is_Causal_Consistency)
- [MIT 6.824: Lecture 17 - Causal Consistency, COPS](https://timilearning.com/posts/mit-6.824/lecture-17-cops/)
- [Mongodb: Causal Consistency and Read and Write Concerns](https://www.mongodb.com/docs/manual/core/causal-consistency-read-write-concerns/)

### eventual consistency

## Replication
- `Designing Data Intensive Applications Chapter 5 Replication`
### Models of Replication
- Leaders and Followers
- Multi-Leader Replication
- Leaderless Replication

### Write Ahead Log
- [Martin Fowler: Write-Ahead Log](https://martinfowler.com/articles/patterns-of-distributed-systems/wal.html)
- [Distributed Services with Go: Chapter 3 Write a Log Package](https://www.oreilly.com/library/view/distributed-services-with/9781680508376/f_0025.xhtml)
- [PostGreSQL: 30.3. Write-Ahead Logging (WAL)](https://www.postgresql.org/docs/current/wal-intro.html)
- [MongoDB Oplog](https://www.mongodb.com/docs/manual/core/replica-set-oplog/)

### PostGreSQL
- physical v.s. Logical streaming replication

### MongoDB
- [MongoDB Manual: Replication](https://www.mongodb.com/docs/manual/replication/)

## Partition

## Raft (Consensus Algorithm)
- [The Raft Consensus Algorithm](https://raft.github.io/)
- [The Secret Lives of Data: Raft](http://thesecretlivesofdata.com/raft/)
- [Distributed Systems 6.2: Raft](https://youtu.be/uXEYuDwm7e4)
- [University of Cambridge: Distributed Systems](https://www.cl.cam.ac.uk/teaching/2122/ConcDisSys/dist-sys-notes.pdf)

## RUM Conjecture
> The Trade offs Behind Modern Storage Systems
- [The RUM Conjecture](http://daslab.seas.harvard.edu/rum-conjecture/)
- [The Trade offs Behind Modern Storage Systems](https://edward-huang.com/distributed-system/2021/01/24/the-trade-offs-behind-modern-storage-systems/)
- [Youtube: Algorithms behind Modern Storage Systems](https://youtu.be/wxcCHvQeZ-U)

