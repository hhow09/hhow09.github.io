# Javascript Dev Notes

## 1. `console.log` an Object is pass by reference

- object is pass by reference
- object may have changed when log shows

> Don't use console.log(obj), use console.log(JSON.parse(JSON.stringify(obj))).

> This way you are sure you are seeing the value of obj at the moment you log it. Otherwise, many browsers provide a live view that constantly updates as values change. This may not be what you want.

- reference: [Logging objects](https://developer.mozilla.org/en-US/docs/Web/API/Console/log#logging_objects)

---

## 2. Initializing 2D array with `Array.fill`

- if filled value is Object, Array or function, e.g. pass by reference, they will reference to the same object.

```javascript
const list = new Array(3).fill(new Array(4).fill(1));
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

- list1 filled each row with `same reference` of `new Array(4).fill(1)`. if modified `list[1][2]`, every row of index 2 will also be modified.
- list two is creating 2D array of each different row.

---

## 3. Deep Copy v.s. Shallow Copy

#### Shallow Copy

1. Array.prototype.slice()
2. Object.assign({}, obj);
3. Spread Syntax: A2 = {...A1}

#### Deep Copy

1. `JSON.parse(JSON.stringify(object))`

- If you do not use `circular reference`, `Dates`, `functions`, `undefined`, `Infinity`, `RegExps`, `Maps`, `Sets`, `Blobs`, `FileLists`, `ImageDatas`, `sparse Arrays`, `Typed Arrays` or other complex types within your object, it is a very simple one liner to deep clone an object.

2. with library: [lodash - cloneDeep](https://lodash.com/docs#cloneDeep)

---

## 4. Manipulating with floating-point number

- JavaScript has a single and unpredictable number type, 64-bit floating point.

```javascript
0.1 + 0.2 === 0.3; // false

function numbersCloseEnoughToEqual(n1, n2) {
  return Math.abs(n1 - n2) < Number.EPSILON;
}

numbersCloseEnoughToEqual(0.1 + 0.2, 0.3);
```

---

## 5. Function arguments are pass-by-reference

```javascript
function foo(x) {
  x.push(4);
  x; // [1,2,3,4]
  x = [4, 5, 6]; //re-assign, reference changed
  x.push(7);
  x; // [4,5,6,7]
}
var a = [1, 2, 3];
foo(a);
a; // [1,2,3,4]
```

---

## 6. Key order of `Object.keys(obj)`?

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
- Order
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

## 7. Remove Duplicate Element in Array

```javascript
const chars = ["A", "B", "A", "C", "B"];

const uniqueChars = chars.filter((c, index) => chars.indexOf(c) === index);
//[ 'A', 'B', 'C' ]
```

---

## Reference

- You Don't Know JS
- [Property order is predictable in JavaScript objects since ES2015](https://www.stefanjudis.com/today-i-learned/property-order-is-predictable-in-javascript-objects-since-es2015/)
