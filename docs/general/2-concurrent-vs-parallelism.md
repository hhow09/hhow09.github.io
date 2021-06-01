# Concurrency vs. Parallelism

## Intro

- CPU will manage/scheduling its own `threads`.
- `Multi-threading` is the prerequisite of `multi-processing`

---

## Multi Threading
![Multi Thread](/img/general/2-concurrent-vs-parallelism/thread-process.jpeg)

### Benefits of Multi Threading
#### Responsiveness
- Multi-threading in an interactive application may allow a program to continue running even if a part (thread) of it is blocked or is performing a lengthy operation, thereby increasing responsiveness to the user.

#### Resource Sharing
- (Compared to)`Processes` may share resources only through techniques such as `Message Passing` and `Shared Memory`.
- However, `threads` share the memory and the resources of the process to **which they belong by default**.

#### Economy
- Allocating memory and resources for `process` creation is a costly job in terms of time and space.
- `Threads` share memory with the process **it belongs**, it is more economical to create and context switch threads. 

#### Scalability
- If there is only one thread then it is not possible to divide the processes into smaller tasks for `parallelism`.
- Single threaded process can run only on one processor regardless of how many processors are available.

---

## 1. Concurrency (Multi threading)
![Concurrency](/img/general/2-concurrent-vs-parallelism/concurrency.png)

- An application is making progress **on more than one task at a time** inside the application, resulting in a `multi-threaded process` (e.g. [goroutine](https://golang.org/ref/mem) in Golang).
- In contrast to:  `Sequential Execution`
- When executing `multi-threaded process` on **a processor**, the processor can switch execution resources between threads, resulting in concurrent execution.
- When talking about concurrency we talk about something happen **on a singe processor**.

- `Promise` in Javascript is `asynchronous programming` but not `Concurrency`.

## 2. Parallel Execution
![Parallel Execution](/img/general/2-concurrent-vs-parallelism/parallel-execution.png)

- A `multi-threaded process` executed in a **shared-memory multi-CPU environment**.
- `threads` are distributed among multiple CPUs at the same time.
- `threads` on different CPUs are executed in parallel.

- `Parallel Execution` **is not equal to** `parallelism`. 

## 3. Parallel Concurrent Execution
![Parallel Concurrent Execution](/img/general/2-concurrent-vs-parallelism/parallel-concurrent-execution.png)

- Simply the [1. Concurrency (Multi threading)](#1-concurrency-multi-threading) + [2. Parallel Execution](#2-parallel-execution) both happens.

- `threads` executed on a CPU are executed concurrently
- `threads` executed on different CPUs are executed in parallel.

## 4. Parallelism (Multi Processing)

![Parallel Concurrent Execution](/img/general/2-concurrent-vs-parallelism/parallelism.png)

- When executing `multi-processing program` on **multiple processors**, tasks are split int sub-tasks and process by multiple threads.
- Resource are isolated among processors.
- Each process can have many threads running in its own memory space. 

### Scenarios
- multi-core processors
- graphics processing unit (GPU)
- field-programmable gate arrays (FPGAs)
- distributed computer clusters


## Reference 
- [Concurrency vs. Parallelism](http://tutorials.jenkov.com/java-concurrency/concurrency-vs-parallelism.html)