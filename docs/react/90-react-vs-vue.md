---
sidebar_position: 90
---
# React v.s. Vue

## tl;dr
- In React, you output everything from DOM markup.
- In Vue, you energize template markup.

- In React, data flows down into the DOM markup.
- In Vue, data flows up into the DOM markup.

- React is `one-way data flow`. 
- Vue is `two-way binding`.


## Intro

前端發展快快速，newbie 總會思考到底該學哪個前端框架，選擇因素包含個人喜好、工作機會、使用族群、社群廣泛度等等。那學了一個還要學第二個嗎？學了多個就會變資深嗎？
剛開始是學 React，很多人說 Vue 學起來更簡單，社群也在逐漸增加，但更簡單就是好嗎？更簡單我猜測意味著框架幫你把一些事情做掉了，只要使用他提供的 API 即可。Vue 的確提供了更多的 API，例如不用自己寫 handleChange，可以不用管 Lifecycle。React 還要自己寫這些。
原本因個人喜好到現在還是沒有真正寫過 Vue，只有看過一些教學文章。但後來發現 React 夠熟悉抽象化邏輯，更能看清楚兩者差異，即使之後要改寫 Vue 應該也可以快速上手，其實最大的差異就是在 Vue 寫 template markup 跟 React 寫 DOM markup 的差別，一個是 render 後，一個是 render 前。下方文章用抽象蠻好的描述了兩者差異。

另外是，發現 Vue3.0 推出，在 functional programming 上跟 React 走更近了。

## React & Hook / [Vue Composition API](https://composition-api.vuejs.org/)

| React & Hook                                                          | Vue Composition API                                                                             |
| --------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| [Context: Provider & Consumer](https://reactjs.org/docs/context.html) | [provide & inject](https://composition-api.vuejs.org/api.html#dependency-injection)             |
| state: useState                                                       | [ref](https://composition-api.vuejs.org/api.html#ref)                                           |
| state: derived state                                                  | [computed(() => state.value...)](https://composition-api.vuejs.org/api.html#computed)           |
| Lifecycle: useEffect(,[]) & ComponentDidMount                         | [setup()](https://composition-api.vuejs.org/api.html#setup)                                     |
| Lifecycle: useEffect                                                  | [watchEffect(()=>{mutate state here} )](https://composition-api.vuejs.org/api.html#watcheffect) |

## Vue vs React 對比的想法 (附上不專業翻譯)

> But my opinion very importantly hinges upon knowledge of immutable, unidirectional data flow patterns that I learned in React. Knowing those made me a better developer period.
>
> React is more like writing pure JavaScript modules in node.js.
>
> React 更像是在 node.js 中編寫純 JavaScript module。
>
> Both React and Vue are all about that single-file component life.
>
> React 和 Vue 都與 single-file 組件的 lifecycle 有關。
>
> I think we need both and should keep both around.
>
> In both you are standing beside a river of data flow.
>
> 在這兩種方法中，您都站在 data flow 旁。
>
> In React, you are standing upstream of the render loop.
>
> 在 React 中，您位於 render loop 的上游。
> In Vue, you are standing downstream of the render loop.
>
> 在 Vue 中，您位於 render loop 的下游。（更像在寫 template)
>
> In this way, they are the inverse of each other.
>
> 在這方面他們彼此相反。
>
> Vue is like inside-out React.
>
> In React, you output DOM markup.
>
> 在 React 中，你輸出 DOM markup。
>
> In Vue, you energize template markup.
>
> 在 Vue 中，你使 template markup 動起來。
>
> In React, data flows down into the DOM markup.
>
> 在 React 中，數據向下流入 DOM markup。
>
> In Vue, data flows up into the DOM markup.
>
> 在 Vue 中，數據向上流入 DOM 標記。
>
> At the end of the day, I just want access to pure JavaScript everywhere, instantly. React and Vue both give me that. In both, if you focus on making as many stateless, deterministic components as possible, you will always have an impressive set of atomically composable SFCs around, and you can slap the roof on those badboys and put them into any state container components. Often times I am surprised I get paid to do this stuff because I just love it. There is something abstract-geometrically beautiful about composing algebraic types within continuous and differentiable data flows.
>
> 歸根究底，我只想立即在任何地方訪問純 JavaScript。 React 和 Vue 都給了我。 在這兩種方法中，如果您專注於製造盡可能多的 stateless，確定性組件，則始終會有一組令人印象深刻的原子可組合 SFC，並且可以在這些壞傢伙身上搭起屋頂，並將它們放入任何狀態容器組件中。 很多時候，我很驚訝我會因為做這件事而得到報酬，因為我只是喜歡它。 在連續且可區分的 data flow 中組成代數類型在某種程度上具有抽象幾何的美。
>
> Try Vue with Tailwind and you will really blow your mind if you have passion for atomic design.

## Reference

- [React Hooks vs Vue 3 Composition API](https://academy.esveo.com/en/blog/Yr/)
- [Vue-單一元件檔(Single-file components)](<https://leahlin912.github.io/2019/06/12/Vue-%E5%96%AE%E4%B8%80%E5%85%83%E4%BB%B6%E6%AA%94(Single-file%20components)/>)
- [Just started vue coming from react. Does anyone else feel that vue makes RIDICULOUSLY more sense than react??](https://www.reddit.com/r/vuejs/comments/e52ec8/just_started_vue_coming_from_react_does_anyone/)
