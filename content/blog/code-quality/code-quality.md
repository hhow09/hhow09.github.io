---
title: Talking about code quality
description: About code quality and personal experience
date: 2025-12-29
tags:
  - code quality
  - programming
layout: layouts/post.njk
---

## What is code quality?
Definitions of code quality is pretty subjective and different from company to company. Developers also have different opinions on what is good code.

In general, code quality is a way to talk about how correct, readable, reusable, maintainable and efficient code is.

- correct: free of bugs and errors
- readable: clean and understandable
- reusable: modular and adaptable
- maintainable: easy to [refactor](https://refactoring.guru/refactoring) and extend
- efficient: optimal performance

## Why is code quality important ?
- Reduces bugs and errors → faster, more stable releases
- Efficient code scales better → improved UX, reduce compute costs
- Helps developers understand, review, collaborate and build upon their own code → faster iterations

## How to measure code quality?
Quantifying code quality is challenging, but these metrics provide useful signals:

- **Test coverage**
    - Also integrate coverage reports with your platform, e.g. [GitLab Code Coverage](https://docs.gitlab.com/ci/testing/code_coverage/)
- **Production bug count**
    - E.g. [Sentry](https://docs.sentry.io/product/) (Error monitoring tool)
- **[Code churn](https://linearb.io/blog/what-is-code-churn)**: frequency of edits to the same code—high churn often indicates implementation struggles
- **[Cyclomatic complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity)**: measures code path complexity
- **Confidence in [refactoring](https://refactoring.guru/refactoring)**: how comfortable the team feels changing code or upgrading dependencies

### Further Reading
- [Software Quality Metrics](https://axify.io/blog/software-quality-metrics)


## How to maintain code quality?
### Correctness
- first and important step, engineers need to ensure the code follows the requirements and specifications.
- It also means the code is free of bugs and errors.

#### In practice
- Enforce **type checking** for dynamically-typed languages to catch type errors at compile time.
- Setup **unit tests** and **integration tests** in CI to catch bugs and errors early.
    - Take [Test-driven development (TDD)](https://en.wikipedia.org/wiki/Test-driven_development) as a guide.
    - Write unit tests covering edge cases and common scenarios.
    - Test integration happy paths at minimum (adjust based on team needs) since it takes more time to write and maintain.
    - Still, **race condition** remain challenging to test: Go has a [Race Detector](https://go.dev/doc/articles/race_detector) but for Node.js.
- Run linter checks in CI to catch code smells 
    - e.g. [eslint](https://eslint.org/), [golangci-lint](https://golangci-lint.run/)
    - Consider configs from big tech: e.g. [eslint-config-airbnb](https://www.npmjs.com/package/eslint-config-airbnb)
- Fix [flaky integration tests](https://www.datadoghq.com/knowledge-center/flaky-tests/) ASAP. 
    - "Don’t live with broken windows." - [The Pragmatic Programmer](https://www.amazon.de/Pragmatic-Programmer-Journeyman-Master/dp/020161622X)

### Readability
Code should be easy to understand, review, and maintain.

#### Complexity
Complexity directly impacts readability.

[A Philosophy of Software Design](https://www.amazon.de/Philosophy-Software-Design-John-Ousterhout/dp/1732102201) by John Ousterhout explores software complexity (e.g. cognitive load) and strategies to reduce it.

#### In practice
- When writing code, follow [Clean Code](https://de.wikipedia.org/wiki/Clean_Code) principles:
    - meaningful naming
    - function should do one thing only
    - comments should explain why not what.
- [Strategic Programming over Tactical Programming](https://web.stanford.edu/~ouster/cgi-bin/cs190-winter18/lecture.php?topic=working)
- Use **code formatter**: e.g. [prettier](https://prettier.io/)
- Follow language-specific guides: e.g. [Effective Typescript](https://effectivetypescript.com/), [Effective Go](https://go.dev/doc/effective_go)

### Reusability
- When implementing similar logic across entities or services, reusable code becomes valuable.
- However, abstraction should be done with care, premature generalization actually creates complexity. see [Rule of three](https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming))

#### In practice
- Follow the [DRY principle](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) thoughtfully.

### Maintainability
Maintainability is about how easy it is to refactor and extend the code.

#### In practice
- [SOLID](https://en.wikipedia.org/wiki/SOLID) principles
- The software is divided into discrete, independent modules or components, each with a clear and specific functionality.
    - "Module should be deep."  - [A Philosophy of Software Design](https://www.amazon.de/Philosophy-Software-Design-John-Ousterhout/dp/1732102201)
- **Management of dependencies** 
    - **Prevent Circular dependency** as much as possible
        - Golang [prevents circular dependency by design](https://go.dev/ref/spec#Import_declarations): "It is illegal for a package to import itself, directly or indirectly"
        - [Node.js Design Patterns](https://www.packtpub.com/en-us/product/nodejs-design-patterns-9781839214110) Chapter 2 The Module System has a good explanation on module loading and circular dependency.
        - Use [eslint-plugin-import/no-cycle](https://github.com/import-js/eslint-plugin-import/blob/main/docs/rules/no-cycle.md) to catch circular dependency.
        - Use [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) to validate/visualize dependencies and define fine-grained dependency rules.
    - **Proper scope of external dependency** into separate modules, e.g. database layer, network layer (http). In this way, change scope of library update could be clearly scoped


### Efficiency
Efficiency can be defined as, using the resources optimally where resources could be memory, CPU, time, files, connections, databases etc.

#### In practice
- write efficient code, understand and minimize time and space complexity of the code.
- Measure before optimizing: Don't optimize performance before you measure it. E.g.
    - End-to-end: [Sentry - Performance Monitoring](https://docs.sentry.io/product/sentry-basics/performance-monitoring/)
    - Database: [Mongo Atlas Monitoring](https://www.mongodb.com/docs/atlas/monitor-cluster-metrics/)
    - Frontend: [Lighthouse](https://developer.chrome.com/docs/lighthouse)


## Further Reading
- [How to create software quality.](https://lethain.com/quality/) by Will Larson discusses software quality in a broader sense.

## References
- [AWS:What is code quality?](https://aws.amazon.com/what-is/code-quality/)
- [Microsoft: Engineering Fundamentals Playbook: Maintainability](https://microsoft.github.io/code-with-engineering-playbook/non-functional-requirements/maintainability/)
- [The Pragmatic Programmer](https://www.amazon.de/Pragmatic-Programmer-Journeyman-Master/dp/020161622X)
- [Clean Code](https://de.wikipedia.org/wiki/Clean_Code)
