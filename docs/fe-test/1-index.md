# Frontend Test

> The more your tests resemble the way your software is used, the more confidence they can give you.


## Types of Test
![Frontend Test Trophy](/img/fe-test/1-index/fe-test-trophy.jpeg)

1. **End to End test**
    - A helper robot that behaves like a user to click around the app and verify that it functions correctly. Sometimes called `functional testing` or `e2e`. 
    - Framework: [cypress](https://www.cypress.io/)
2. **Integration test**
    - It validate **how multiple units of your application work together** but are more lightweight than E2E tests. 
    - [Jest](https://jestjs.io/) uses `jsdom` under the hood to **emulate common browser APIs** with less overhead than automation
    - [Jest](https://jestjs.io/) has robust mocking tools to stub out external API calls.
3. **Unit test**
    - Verify that individual, isolated parts work as expected.
    - They are easy to write, but can miss the big picture.
    - Framework: [Jest](https://jestjs.io/)
4. **Static test**
    - Catch typos and type errors as you write the code. 
    - Framework:  `ESLint`, `Typescript`

---
## Jest: Coverage Report
![Jest Coverage Report](/img/fe-test/1-index/jest-coverage.png)

- `Statements` represent **instructions** that have been executed at least once during the unit tests. 
- `Branches` represent if **statements which conditions** have been fulfilled at least once during the unit tests.
- `Functions` represent **functions** that have been called at least once during the unit tests.
- `Lines` represent **code lines** that have executed at least once during the unit tests.


## Jest: Set up Guide
- [Testing React Apps](https://jestjs.io/docs/tutorial-react)
- [Setting Up Testing Library with NextJS](https://frontend-digest.com/setting-up-testing-library-with-nextjs-a9702cbde32d)
- [React: Testing Recipes](https://reactjs.org/docs/testing-recipes.html)

## Reference
- [Static vs Unit vs Integration vs E2E Testing for Frontend Apps](https://kentcdodds.com/blog/unit-vs-integration-vs-e2e-tests)
- [Setting Up Testing Library with NextJS](https://frontend-digest.com/setting-up-testing-library-with-nextjs-a9702cbde32d)
- [Combining Storybook, Cypress and Jest Code Coverage](https://dev.to/penx/combining-storybook-cypress-and-jest-code-coverage-4pa5)