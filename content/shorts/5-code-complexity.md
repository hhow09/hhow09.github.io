---
title: Code complexity
description: What makes the code complex?
date: 2026-02-08
tags:
  - shorts
layout: layouts/short.njk
---

## Can we measure software complexity? 

[Reddit - Measuring Software Complexity: What Metrics to Use?](https://www.reddit.com/r/programming/comments/r3csi8/measuring_software_complexity_what_metrics_to_use/)

> WTFs per minute in code review. Very reliable.

> The frequency with which someone tracing a code path forgets what they were trying to figure out.

I don't think there is a metrics to measure software complexity since it's not going to be objective. 

## Cognitive load are underestimated
- Cognitive load is a real thing. It does cost time and money.
- Defect counts are directly related to complexity.


Necessary complexity comes from product, business domain which is unavoidable and valuable. But we should reduce unnecessary complexity.

## What makes the code complex (while it doesn't have to)?
### Condition blowup
- E.g. In UI layer, before displaying something, we usually need to check (1) user's permission (2) entity type (3) entity state (implcity + explicit ones). These combination could result in significant cognitive load.
- Solution: replace implicity entity state from if-else to [finite state machine](https://gameprogrammingpatterns.com/state.html).
    - when mutiple mutually exclusive states can be discovered.
    - read also: [Designing with types: Making state explicit](https://fsharpforfunandprofit.com/posts/designing-with-types-representing-states/)

### Unexpected side effect
- E.g. having side effect in getter function. 
- E.g. When your util modules is not pure (which it should be!) and can actullay perform database update. Tracing data flow becomes a nightmare because you need to go over every function.

(TBD...)

## Compile-time complexity over runtime complexity
- Go's error handling makes the error handling logic explicit.
- Rust's syntax level [ownership system](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html) actually makes the memory management issue explicit. 
