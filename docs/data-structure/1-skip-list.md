# Skip List

## What is Skip List?

- A skip list is a `probabilistic` data structure.
- A skip list takes `O(log(n))` time to `add`, `erase` and `search`, which is not possible in `array` or `linked list`
- A skip list has the same function and performance comparing with `treap` and `red-black tree`.
- That the skip list can be interpreted as a type of `randomly balanced tree`

## Data Structure

![skip list structure](/img/data-structure/1-skip-list/skiplist.svg)

- a node: contains
  - value `val`
  - height `h`
  - a list of pointers `node[] next` from level 0 to level h.
  - The next[i] representing the pointer of level `i` which points to the next node of same level i.
- listHeight: The height of a skip list is the height of its tallest node.
- MaxHeight: A constant that limit the height of skip list.
- sentinel: the dummy head node of list of every level.
  - usually initialize with value of `Number.MIN_SAFE_INTEGER`, h of `MaxHeight-1`
  - Every search starts from sentinel.
- probability `p`: If a node contains level from 0 to i, **the probability that it has `i+1` level.**

## Search

### The search path for the node containing 4.

![skiplist-searchpath](/img/data-structure/1-skip-list/skiplist-searchpath.svg)

- The higher the level, the sparser the list.
- Search starts from high level to low level.
- Some nodes are skipped during search, resulting in the similarity to `binary search`.

### Search Algorithm

```java
    // find the predecessor
    private Node findPred(int num) {
        Node cur = sentinel;
        for (int r = topLevel; r >= 0; r--) {
            while (cur.next[r] != null && cur.next[r].val < num)  cur = cur.next[r];
            stack[r] = cur;
        }
        return cur;
    }

    public boolean search(int target) {
        Node pred = findPred(target);
        return pred.next[0] != null && pred.next[0].val == target;
    }
```

## Add

### Adding an element to a skip list

![Adding an element to a skip list](/img/data-structure/1-skip-list/skiplist-addix.svg)

```java
    private int pickHeight() {
        return Math.floor(Math.random() * MAX_HEIGHT);
    }
    public void add(int num) {
        Node pred = findPred(num);
        if (pred.next[0] != null && pred.next[0].val == num) {
            pred.next[0].count++;
            return;
        }
        Node newNode = new Node(num, pickHeight());
        while (topLevel < newNode.h) stack[++topLevel] = sentinel;
        for (int i = 0; i <= newNode.h; i++) {
            //connect all prev and next nodes of level 0 - newNode.h
            newNode.next[i] = stack[i].next[i];
            stack[i].next[i] = newNode;
        }
    }
```

## Performance

- A skip list of `n` nodes and probability `p`.
- Node number of level i is `n * p^(i-1)`
  - first level: `n`
  - second level: `n * p`
  - third level: `n * p^2`
- average search length is the order of `log(n)`

## Balanced Tree v.s. Skip List

- `search`, `insertion` and `deletion` of balanced tree is more complex than skip list
- TODO

## Application

- Redis
- Lucene / Elasticsearch

## Reference

- [Leetcode 1206. Design Skiplist](https://leetcode.com/problems/design-skiplist/)
- [Open Data Structure 4 Skiplists](https://opendatastructures.org/newhtml/ods/latex/skiplists.html#tex2htm-54)
- [Redis 内部数据结构详解(6)——skiplist](http://zhangtielei.com/posts/blog-redis-skiplist.html)
