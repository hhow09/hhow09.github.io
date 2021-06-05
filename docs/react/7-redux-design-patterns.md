# Design Patterns in Redux

## Flux

### Flux Architecture

![Flux Architecture](/img/react/7-redux-design-patterns/flux-architecture.png)

### Flux v.s. Redux

![Flux v.s. Redux](/img/react/7-redux-design-patterns/redux-vs-flux.png)

//TODO

---

## Extension

### Store: Singleton Pattern

> Singleton Pattern is a design pattern that restricts the instantiation of a class to one object.

- There is only one state tree known as `Store` in Redux.
- Store is Single source of truth.

### Connect/Selector: Observer Pattern

> An object, called the subject, maintains a list of its dependents, called observers, and notifies them automatically of any state changes.

### applyMiddleware: Decorator Pattern / HOF

> designed to enhance functionality, but does not change the interface

## Reference

- [An introduction to the Flux architectural pattern](https://www.freecodecamp.org/news/an-introduction-to-the-flux-architectural-pattern-674ea74775c9/)
- [An Obsession with Design Patterns: Redux](https://engineering.zalando.com/posts/2016/08/design-patterns-redux.html?gh_src=4n3gxh1?gh_src=4n3gxh1)
- [Difference between redux and flux](https://enappd.com/blog/difference-between-redux-and-flux/106/)
