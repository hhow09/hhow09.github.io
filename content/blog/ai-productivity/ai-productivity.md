---
title: AI productivity boost is real
description: My workflow on using AI tools to improve efficiency.
date: 2026-02-12
tags:
  - productivity
  - ai
layout: layouts/post.njk
---

I was a bit skeptical about AI coding assistant at first. But since Skills came out, I can really feel the power of agentic workflow. My workflow is still heavy **human in the loop** but I can certainly get better result with better custom rule, templates.

I use Cursor since my company paid for it. 

## 1. [Plan Mode](https://cursor.com/docs/agent/modes#plan)

Plan Mode is extremely useful for complex tasks.

Here is how I used it:

1.  **Plan**
    - **Seperation of concerns**
        - separate the plan into different files for different phases of task. 
        - `SPEC.md`: user story, requirements, etc. which will discuss with PM.
        - `TECHNICAL_DETAIL.md`: architecture, data flow, api design, complexity analysis, etc. which will discuss with technical roles.
        - `IMPLEMENTATION.md`: implementation plan, which will be updated throughout the implementation process.
    - use `SPEC.md` and `TECHNICAL_DETAIL.md` to **Understand the problem / spec** by asking
        - "Given the spec from jira ticket <link>, understand the current user story deeply with following references: <files>. Provide flow chart."
            - Ref: [jira MCP](https://www.atlassian.com/blog/announcements/remote-mcp-server)
        - "Grill me with specs I need to clarify with product manager. List out possible edge cases."
        - "Explain the current architecture of <module1>, <module2>. Draw a diagram to visualize the flow and architecture."
    - use `IMPLEMENTATION.md` to **Break down into smaller tasks** by asking
        - "Break features into small, focused tasks"
        - "What's the suggested priority of these tasks in order to minimize the risk of breaking existing features?"
        - "What's the required changes for each task?" to understand the complexity for better estimation.
    - **Context**: Always provide relevant context: specific code reference, document.
2.  **Execute first few steps for quick validation**: Execute the initial steps to validate the approach before committing to the full implementation.
3. **Implementation**:  Update the plan accordingly every round based on the real AI + human implementation.
4.  **Futher usage**: keep the plan in a directory for futher use: decision making reference, QA testing instructions, tech sharing materials, work log, etc.



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

## 5. MCPs
- [Atlassian Remote MCP Server](https://www.atlassian.com/blog/announcements/remote-mcp-server)

## Other tools to try
- Code review in CI: [Code Review with Cursor CLI](https://cursor.com/docs/cli/cookbook/code-review)
- Hooks: [https://cursor.com/docs/agent/hooks](https://cursor.com/docs/agent/hooks)
- Analyze Chat history for personal Self-Insight.

---

## What are still heavily human involved
- clarify requirements: When product get complex, spec could be easily overlooked by both PM and Dev even with the help of AI. 
  - Integrating existing company knowledge as context when writing spec should help. 
- debugging: Jumping between tickets, UI, logs, and codebase are still too complex for AI to handle alone.

## Thoughts: Bottleneck shifted
Bottleneck of delivery shifted from coding to review and other processes (testing, external dependency, release process), as stated in several posts ([1](https://blog.logrocket.com/ai-coding-tools-shift-bottleneck-to-review/), [2](http://reddit.com/r/softwaredevelopment/comments/1m0i8cx/team_burnout_from_code_review_bottlenecks_how_do/)). New challenges already emerged: large amount of low quality PR from unexperienced engineer, human QA as relase blocker...

## Ref
- [How I Use Claude Code](https://boristane.com/blog/how-i-use-claude-code/)
- [My LLM coding workflow going into 2026](https://addyosmani.com/blog/ai-coding-workflow/)
- [Cursor Agent Best Practices](https://cursor.com/blog/agent-best-practices)