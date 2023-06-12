---
title: Tunable Consistency in MongoDB
description: paper notes
date: 2023-06-13
tags:
  - distributed system
  - mongo db
layout: layouts/post.njk
draft: true
---

paper: [Tunable Consistency in MongoDB](https://www.vldb.org/pvldb/vol12/p2071-schultz.pdf)

## Introduction

- One of the main goals of the MongoDB replication system is to provide a highly available distributed data store that lets users explicitly decide among the trade-offs available in a replicated database system. 
- For example, in a replicated database, paying the cost of a full quorum write for all operations would be unnecessary if the system never experienced failures.
- MongoDB exposes `writeConcern` and `readConcern`
- MongoDB introduced [causal consistency](https://www.mongodb.com/docs/manual/core/causal-consistency-read-write-concerns/) in version 3.6 which provides clients with an additional
set of optional consistency guarantees 

## Background
- In contrast to Raft
    - replication of log entries in MongoDB is **pull-based**, which means that secondaries
fetch new entries from any other valid primary or secondary node.
    - nodes apply log entries to the database "speculatively", as soon as they receive them, rather than
waiting for the entries to become majority committed.


## Consistency Levels In MongoDB


## Reference 
- [Causal Consistency and Read and Write Concerns](https://www.mongodb.com/docs/manual/core/causal-consistency-read-write-concerns/)