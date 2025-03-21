---
title: Session guarantees for weakly consistent replicated data
description: 'Four per-session guarantees are proposed to aid users and applications of weakly consistent replicated data: "read your writes", "monotonic reads", "writes follow reads", and "monotonic writes".'
date: 2024-02-14
tags:
  - distributed system
layout: layouts/post.njk
---

## Introduction
**Eventual Consistency** is not enough.

> The term “eventually” is deliberately vague: in general, there is no limit to how far a replica can fall behind. [^2]

> Unfortunately, the lack of guarantees concerning the ordering of read and write operations in weakly consistent systems can confuse users and applications, as reported in experiences with Grapevine [21]. A user may read some value for a data item and then later read an older value. Similarly, a user may update some data item based on reading some other data, while others read the updated item without seeing the data on which it is based. [^1]



## Consistency Models [^3]
{% image "./consistency-models.png", "Consistency Models by JEPSEN" %}


## PRAM Consistency [^3] [^4]
- PRAM stands for Pipeline Random Access Memory.
- PRAM is exactly equivalent to [read your writes](#read-your-writes), [monotonic writes](#monotonic-writes), and [monotonic reads](#monotonic-reads).

### Defition
> all processes see write operations issued by a given process in the same order as they were invoked by that process. 

> On the other hand, processes may observe writes issued by different processes in different orders.

## Notations
1. `DB(S)`: the current contents of the server's database. 
1. `DB(S,t)`: the ordered sequence of Writes that have been received by server `S` at or before time `t`.
1. `WriteOrder(W1,W2)`: a boolean predicate indicating whether Write `W1` should be ordered before Write `W2`


## Session Guarantees

> Sessions are not intended to correspond to atomic transactions that ensure atomicity and serializability. Instead, the intent is to present individual applications with a view of the database that is consistent with their own actions, even if they read and write from various, potentially inconsistent servers. We want the results of operations performed in a session to be consistent with the model of a single centralized server, possibly being read and updated concurrently by multiple clients. [^1]


### Read Your Writes
> read operations reflect previous writes.

> If Read R follows Write W in a session and R is performed at server S at time t, then W is included in `DB(S,t)`.

- this guarantee is limited within a session.

#### Examples [^1]
1. Shortly after changing password, user would occasionally type the new password and receive an "invalid password" response. The **RYW-guarantee** ensures that the login process will always read the most recent password.

2. As a user reads and deletes messages, those messages are removed from the displayed "new mail" folder. If the user stops reading mail and returns sometime later, she should not see deleted messages reappear simply because the mail reader refreshed its display from a different copy of the database.

### Monotonic Reads
> successive reads must reflect a non-decreasing set of writes.

> Namely, if a process has read a certain value v from an object, any successive read operation
will not return any value written before v.

- this guarantee is limited within a session.

#### Examples [^1]
1. The user's calendar program periodically refreshes its display by reading all of today's calendar appointments from the database. If it accesses servers with inconsistent copies of the database, recently added (or deleted) meetings may appear to come and go. The **MR-guarantee** can effectively prevent this since it disallows access to copies of the database that are less current than the previously read copy.

### Monotonic Writes
> If Write W1 precedes Write W2 in a session, then, for any server S2, if W2 in `DB(S2)` then W1 is also in `DB(S2)` and `WriteOrder(W1,W2)`.

> If a process performs write w1, then w2, then all processes observe w1 before w2.

- this guarantee affects **globally**.

#### Examples [^1]
1. A text editor when editing replicated files to ensure that if the user saves version N of the file and later saves version N+1 then version N+1 will replace version N at all servers. In particular, it avoids the situation in which version N is written to some server and version N+1 to a different server and the versions get propagated such that version N is applied after N+1.

### Writes Follow Reads
> writes are propagated after reads on which they depend.

> if a process reads a value v, which came from a write w1, and later performs write w2, then w2 must be visible after w1. Once you’ve read something, you can’t change that read’s past.

- also known as **session causality**

- this guarantee affects **globally**

#### Examples
1. User sees reactions (W) to posted articles only if he/she have read the original posting.

## Database Configurations
### MongoDB[^5]
| Read Concern | Write Concern | Read own writes | Monotonic reads | Monotonic writes | Writes follow reads |
|:------------:|:-------------:|:---------------:|:---------------:|:----------------:|:-------------------:|
| "majority"   | "majority"    | ✅              | ✅              | ✅               | ✅                  |
| "majority"   | { w: 1 }      |                 | ✅              |                  | ✅                  |
| "local"      | { w: 1 }      |                 |                 |                  |                     |
| "local"      | "majority"    |                 |                 | ✅               |                     |

#### Read Concern Majority [^6]
> Majority does a timestamped read at the stable timestamp (also called the last committed snapshot in the code, for legacy reasons). The data read only reflects the oplog entries that have been replicated to a majority of nodes in the replica set. Any data seen in majority reads cannot roll back in the future. Thus majority reads prevent dirty reads, though they often are stale reads.

> Read concern majority reads do not wait for anything to be committed; they just use different snapshots from local reads. Read concern majority reads usually return as fast as local reads, but sometimes will block. For example, right after startup or rollback when we do not have a committed snapshot, majority reads will be blocked. Also, when some of the secondaries are unavailable or lagging, majority reads could slow down or block.

### PostgreSQL [^7] [^8]
> PostgreSQL streaming replication is **asynchronous** by default. If the primary server crashes then some transactions that were committed may not have been replicated to the standby server, causing data loss. The amount of data loss is proportional to the replication delay at the time of failover.
- `synchronous_commit` specifies how much WAL processing must complete before the database server returns a `success` indication to the client. 
  - Valid values are `remote_apply`, `on` (the default), `remote_write`, `local`, and `off`.
- Setting `synchronous_commit` to `remote_write` will cause each commit to wait for confirmation that the standby has received the commit record and written it out to its own operating system, but not for the data to be flushed to disk on the standby. This setting provides a weaker guarantee of durability than `on` does: the standby could lose the data in the event of an operating system crash, though not a PostgreSQL crash. However, it's a useful setting in practice because it can decrease the response time for the transaction. Data loss could only occur if both the primary and the standby crash and the database of the primary gets corrupted at the same time.

- Setting `synchronous_commit` to `remote_apply` will cause each commit to wait until the current synchronous standbys report that they have replayed the transaction, making it visible to user queries. In simple cases, **this allows for load balancing with causal consistency**.

## Reference
[^1]: [Session Guarantees for Weakly Consistent Replicated Data](https://www.cs.cornell.edu/courses/cs734/2000FA/cached%20papers/SessionGuaranteesPDIS_1.html)
[^2]: Designing Data Intensive Applications Chapter 5: Replication
[^3]: [JEPSEN - Consistency Models](https://jepsen.io/consistency)
[^4]: [Consistency in Non-Transactional Distributed Storage Systems](https://dl.acm.org/doi/10.1145/2926965)
[^5]: [MongoDB: Causal Consistency and Read and Write Concerns](https://www.mongodb.com/docs/manual/core/causal-consistency-read-write-concerns/)
[^6]: [MongoDB: Replication Internals](https://github.com/mongodb/mongo/blob/master/src/mongo/db/repl/README.md#read-concern)
[^7]: [PostgreSQL synchronous_commit](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-SYNCHRONOUS-COMMIT)
[^8]: [PostgreSQL: Synchronous Replication](https://www.postgresql.org/docs/11/warm-standby.html#SYNCHRONOUS-REPLICATION)