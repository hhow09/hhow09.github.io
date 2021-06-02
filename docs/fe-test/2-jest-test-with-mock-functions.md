# Jest: Test with Mock Functions

> Mock functions allow you to test the links between code by erasing the actual implementation of a function, capturing calls to the function (and the parameters passed in those calls), capturing instances of constructor functions when instantiated with new, and allowing test-time configuration of return values.

There are two ways to mock functions: 
1. Either by **creating a mock function** to use in test code, 
2. or writing a manual mock to override a module dependency.

## Mock Hooks

```jsx
const useRouter = jest.spyOn(require("next/router"), "useRouter");

describe("Navbar Testing", () => {
  test("Navbar content exists", () => {
    useRouter.mockImplementationOnce(() => ({
      pathname: "/",
    }));
    const { container } = render(<Navbar />);
    expect(container).toMatchSnapshot();
  });
});
```

## Reference
- [Jest: Mock Functions](https://jestjs.io/docs/mock-functions)