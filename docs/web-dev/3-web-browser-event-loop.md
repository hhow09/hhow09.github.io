# Event Loop

![Event Loop](/img/web-dev/3-web-browser-event-loop/event-loop.png)

## Terms

### libuv

- Libuv is an open-source library that handles the thread-pool, doing signaling, inter process communications all other magic needed to make the asynchronous tasks work at all.
- Libuv was originally developed for Node.js

### Task ( = `Macrotask`)

### [Generic task sources](https://html.spec.whatwg.org/multipage/webappapis.html#generic-task-sources)

- DOM manipulation
- User Interaction: keyboard or mouse input
- Network activity
- history traversal：Ex. history.back() API

### Microtask

A `microtask` is a short function which **is executed after the function or program which created it exits and only if the JavaScript execution stack is empty, but before returning control to the event loop being used by the user agent to drive the script's execution environment**.

### Tick

- a complete process of `one event loop` including:
  1. `dequeuing` of an event from the `event loop queue`
  2. the execution of said event.

---

## Event Loop

> macrotask should be processed from the macrotask queue in one tick of the event loop. After this macrotask has finished, all other available microtasks should be processed within the same tick.

//TODO

---

## Reference

- [Using microtasks in JavaScript with queueMicrotask()](https://developer.mozilla.org/en-US/docs/Web/API/HTML_DOM_API/Microtask_guide)
- [Node.js Under The Hood #3 - Deep Dive Into the Event Loop](https://dev.to/khaosdoctor/node-js-under-the-hood-3-deep-dive-into-the-event-loop-135d)
- [我知道你懂 Event Loop，但你了解到多深？](https://yeefun.github.io/event-loop-in-depth/?fbclid=IwAR0zHuodyFada1gfYL2P6CJjbHzxgX8KMAaUAlTsewERngKbswrf0guC-zU)
- [【筆記】到底 Event Loop 關我啥事？](https://medium.com/infinitegamer/why-event-loop-exist-e8ac9d287044)
