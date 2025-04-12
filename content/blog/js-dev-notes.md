---
title: JavaScript/TypeScript Development Notes
description: JavaScript/TypeScript Development Notes
date: 2022-06-19
tags:
  - javascript
  - typescript
layout: layouts/post.njk
---
Some notes and gotchas I met in JS/TS development.

## Trace Call Stack [^trace_v8] [^trace_mdn]

```javascript
function foo() {
  bar();
}

function bar() {
  baz();
}

function baz() {
  console.log(new Error().stack);
}

foo();
```

---

## `console.log` an Object is pass by reference [^console_log_obj]

- object is pass by reference
- object may have changed when log shows

### Solution
- Don't use `console.log(obj)`, use `console.log(JSON.parse(JSON.stringify(obj)))` instead.
- This way you are sure you are seeing the value of obj at the moment you log it. Otherwise, many browsers provide a live view that constantly updates as values change. This may not be what you want.
- Or just use [Debugger](https://code.visualstudio.com/docs/debugtest/debugging)

---

## Deep Copy v.s. Shallow Copy

#### Shallow Copy

1. [Array.prototype.slice()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice)
2. [Object.assign({}, obj)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign)
3. [Spread Syntax: A2 = {...A1}](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax)

#### Deep Copy

1. `JSON.parse(JSON.stringify(object))`. 
    - If you do not use `circular reference`, `Dates`, `functions`, `undefined`, `Infinity`, `RegExps`, `Maps`, `Sets`, `Blobs`, `FileLists`, `ImageDatas`, `sparse Arrays`, `Typed Arrays` or other complex types within your object, it is a very simple one liner to deep clone an object.

2. with library: [lodash - cloneDeep](https://lodash.com/docs#cloneDeep)

---

## Initializing 2D array with [Array.fill](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/fill)

- if the filled value is Object, Array or function (pass by reference), they will reference to the same object.

```javascript
// filled each row with `same reference` of `new Array(4).fill(1)`.
const list = new Array(3).fill(new Array(4).fill(1));
// filled each row with `different reference` of `new Array(4).fill(1)`.
const list2 = new Array(3).fill(null).map(() => new Array(4).fill(1));

list[1][2] = 2;
list2[1][2] = 2;
console.log(list);
// false
//[
//  [ 1, 1, 2, 1 ],
//  [ 1, 1, 2, 1 ],
//  [ 1, 1, 2, 1 ]
//]
console.log(list2);
// correct
//[
//  [ 1, 1, 1, 1 ],
//  [ 1, 1, 2, 1 ],
//  [ 1, 1, 1, 1 ]
//]
```

---

## Manipulate with floating-point number [^you_dont_know_js]
```javascript
0.1 + 0.2 === 0.3; // false

function numbersCloseEnoughToEqual(n1, n2) {
  return Math.abs(n1 - n2) < Number.EPSILON;
}

numbersCloseEnoughToEqual(0.1 + 0.2, 0.3);
```

- Don't calculate by yourself. rely on a library like [decimal.js](https://mikemcl.github.io/decimal.js/) or [big.js](https://github.com/MikeMcl/big.js#readme)

---

## Fetching - Query Param
- Don't use string literal to build query param.
  - Otherwise empty space or `%00` (turn into null) in param will definitely backfire you.
- Use [URLSearchParams](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/URLSearchParams) to build query param.
- Use library like [qs](https://www.npmjs.com/package/qs) to build complex/nested query params.

---

## Key order of `Object.keys(obj)`? [^property_order_es2015]

#### ES5

- depend on browser
- ref: [ECMA 5.0 Object.keys (O)](https://262.ecma-international.org/5.1/#sec-15.2.3.14)

> 5. For each own enumerable property of O whose name String is P
>
> - Call the [[DefineOwnProperty]] internal method of array with arguments ToString(index), the PropertyDescriptor {[[Value]]: P, [[Writable]]: true, [[Enumerable]]: true, [[Configurable]]: true}, and false.
>
> - Increment index by 1.
>
> If an implementation defines a specific order of enumeration for the for-in statement, that same enumeration order must be used in step 5 of this algorithm.

#### ES6:

- depend on [`OwnPropertyKeys`](https://262.ecma-international.org/6.0/#sec-ordinary-object-internal-methods-and-internal-slots-ownpropertykeys) method
    - `Reflect.ownKeys` also depend on `OwnPropertyKeys`
- Order of [`OwnPropertyKeys`](https://262.ecma-international.org/6.0/#sec-ordinary-object-internal-methods-and-internal-slots-ownpropertykeys)
  - `integers`: in numeric order
  - `strings`: in chronological order
  - `Symbols`: in chronological order
- ref: [ECMA 6.0 Object.keys ( O )](https://262.ecma-international.org/6.0/#sec-object.keys)

```javascript
const obj = {
  2: "integer: 2",
  foo: "string: foo",
  "01": "string: 01",
  1: "integer: 1",
  [Symbol("first")]: "symbol: first",
};

obj["0"] = "integer: 0";
obj[Symbol("last")] = "symbol: last";
obj["veryLast"] = "string: very last";

console.log(Reflect.ownKeys(obj));
// [ "0", "1", "2", "foo", "01", "veryLast", Symbol(first), Symbol(last) ]
```

---

## Remove Duplicate Element in Array

```javascript
const chars = ["A", "B", "A", "C", "B"];

const uniqueChars = chars.filter((c, index) => chars.indexOf(c) === index);
//[ 'A', 'B', 'C' ]
```

## DOM Element

### DOM Element is a special object

```javascript
var a = document.createElement("div");
typeof a; // "object"
Object.prototype.toString.call(a); // "[object HTMLDivElement]"
a.tagName; // "DIV"
```

- Cannot call some built-in methods such as `toString()`
- Cannot be overwritten / override some properties such as `this`

### DOM Element will produce global variable

be careful for duplicate naming.

```html
<div id="foo"></div>
```

```javascript
console.log(foo); // HTML Element
```

## using `await` inside `setInterval` is pointless

- since interval won't wait for `await`

```javascript
async function getData (){
  return fetch("url...")
}
const timer = setInterval(
  await getData();
,1000)
```

above code can change into

```javascript
async function getData() {
  return fetch("https://google.com");
}

async function sleep(ms) {
  return await new Promise((resolve) => setTimeout(resolve, ms));
}

function periodicGetData() {
  return new Promise(async (resolve, reject) => {
    if (some_condition) {
      resolve();
    }
    const res = await getData();
    if (res instanceof Error) {
      reject(res);
    }
    console.log("res", res);
    await sleep(1000);
    return periodicGetData();
  });
}
periodicGetData();
```

---

## Reference
[^trace_v8]: [V8: Stack Trace API](https://v8.dev/docs/stack-trace-api)
[^trace_mdn]: [MDN: Error.prototype.stack](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/stack)
[^console_log_obj]: [MDN: Logging objects](https://developer.mozilla.org/en-US/docs/Web/API/Console/log#logging_objects)
[^you_dont_know_js]: [You Don't Know JS](https://github.com/getify/You-Dont-Know-JS)
[^property_order_es2015]: [Property order is predictable in JavaScript objects since ES2015](https://www.stefanjudis.com/today-i-learned/property-order-is-predictable-in-javascript-objects-since-es2015/)
