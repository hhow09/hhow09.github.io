---
title: AI productivity boosts is real
description: My workflow on using AI tools to improve efficiency.
date: 2026-02-12
tags:
  - productivity
  - ai
layout: layouts/post.njk
---

I was a bit skeptical about AI coding assistant at first. But since Skills came out, I can really feel the power of agentic workflow.

I use Cursor but these features should also work in general agents e.g. Claude Code.

Here are the features I've used

## 1. [Plan Mode](https://cursor.com/docs/agent/modes#plan)

Plan Mode is extremely useful to explore the complexities between different solutions before making any changes.

How I used that:

1.  **Plan**
    - Structure the problem first
    - Avoid touching code
    - Draw diagram to visualize the flow and architecture
2.  **Execute first few steps for quick validation**: Execute the initial steps to validate the approach before committing to the full implementation.
3. **implementation**:  Update the plan accordingly every round based on the real AI + human implementation.
4.  **Futher usage**: keep the plan for futher use e.g. decision making reference, QA testing instructions, tech sharing materials, work log, etc.

### TODO
- Use [Planning with Files](https://github.com/OthmanAdi/planning-with-files/tree/master) to consolidate template.


## 2. [Agent Skills](https://cursor.com/docs/context/skills)

open standard for extending AI agents with specialized capabilities.

### I used
- [vercel-react-best-practices](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices)
- perform code review

## 3. [Rules](https://cursor.com/docs/context/rules)

Project based rules to provide contex automatically in chat.

Use cases: general coding guidelines, code structure, testing style

examples: [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules/tree/main)

## 4. Normal Chat / Others
- code trace
- debugging
- writing tests
- commit message generation

## Other tools to try
- Code review in CI: [Code Review with Cursor CLI](https://cursor.com/docs/cli/cookbook/code-review)
- Hooks: [https://cursor.com/docs/agent/hooks](https://cursor.com/docs/agent/hooks)
- Analyze Chat history for personal Self-Insight.


## Ref
- [Cursor Agent Best Practices](https://cursor.com/blog/agent-best-practices)