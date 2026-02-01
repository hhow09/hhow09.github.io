---
title: "Incremental Type Safety: Adopting Strict Mode in Large Projects"
description: How to adopt strict mode in large projects incrementally
date: 2026-02-01
tags:
  - typescript
  - programming
layout: layouts/post.njk
---

In my [previous post](/blog/code-quality/), I discussed how type checking serves as a primary tool to catch errors at compile time. 

This post explores how I helped my team to ensure type safety **incrementally** in a large project without disrupting feature development.

## Why is type safety important?
* **Confidence in change**: When you change code or upgrade dependencies, the compiler will catch missing type errors.
* **Prevent unexpected runtime errors**: It prevents an entire class of runtime logic errors by ensuring data structures are handled predictably.

However, for a legacy codebase, enabling type checking with `tsc` often results in thousands of errors. Fixing them all at once is rarely feasible without disrupting feature development. Yet fixing them without actually enabling type checking cannot prevent new type errors from being introduced.

## The Strategy: Incremental adoption
For most teams, spending an entire sprint fixing type errors is not practical. 

The goal is to move towards a strict type checking environment without a "big bang" refactor. I followed two principles:
1. **New code must be strict**: Stop the broken window.
2. **Existing code is fixed as it's touched**: Refactor legacy files during feature updates.

## Initiatives in typescript repo
I started my survey with the following issues in typescript repo:

- [Issue: Support overriding type-checking compile flags on a per file basis](https://github.com/microsoft/TypeScript/issues/8405)
- [Issue: Strict type-checking on a per-file basis "@ts-strict"](https://github.com/microsoft/TypeScript/issues/28306)

They are either not adopted or still open.

After turning to other open source tools, I found the following the cleanest to use.

## Fixing frontend project
Our project uses webpack as the bundler. With [fork-ts-checker-webpack-plugin](https://github.com/TypeStrong/fork-ts-checker-webpack-plugin), we can run type checking within the webpack build process (`npm run build`).

### 1. Progressive allowlist
Start with an allowlist of files that are already fixed.

```js
new ForkTsCheckerWebpackPlugin({
    files: ["src/path/to/safe/file.ts" , "src/path/to/safe-folder/**/*.ts"],
}),
```

At this point, the listed files are ensured to be type safe.

### 2. Track **known errors**
At a certain point, most files are already fixed. We can then include all files in the checker and track known errors to catch remaining type errors through issue filtering.

```js
const knowTSErrors = require("./knowTSErrors.json");
/// ...
new ForkTsCheckerWebpackPlugin({
    files: ["src/**/*.ts"],
    issue: {
        exclude: (issue) =>
            knowTSErrors.some((item) => {
                const codeMatches = issue.code === item.code
                const fileMatches = issue.file.includes(item.file)
                const severityMatches = issue.severity === item.severity
                return codeMatches && fileMatches && severityMatches
            }),
    },
}),
```

`knowTSErrors.json`.
```json
[
    {
        "code": "TS2339",
        "severity": "error",
        "file": "src/path/to/error/file.ts"
    },
    {
        "code": "TS2564",
        "severity": "error",
        "file": "src/path/to/error/file.ts"
    },
]
```

At this point, the entire project except the listed files is ensured to be type safe.

The rest is fixing the remaining type errors.

## Fixing general Node.js projects
[typescript-strict-plugin](https://github.com/allegro/typescript-strict-plugin/tree/master) was created mainly for existing projects that want to incorporate typescript strict mode, but project is so big that refactoring everything would take ages.

```json
{
  "compilerOptions": {
    ...
    "strict": false,
    "plugins": [
      {
        "name": "typescript-strict-plugin",
        "paths": [
          "./src",
          "/absolute/path/to/source/"
        ],
        "exclude": [
          "./src/tests",
          "./src/fileToExclude.ts"
        ],
        "excludePattern": [
          "**/*.spec.ts"
        ]
      }
    ]
  }
}
```

Just like the frontend strategy, start with an **allowlist** in the `paths` option.

Then add an exclude file list in the `exclude` or `excludePattern` option.

## Alternatives
### [Inside Figma: a case study on strict null checks](https://www.figma.com/blog/inside-figma-a-case-study-on-strict-null-checks/) 
This article shows how Figma adopted strict mode incrementally. They use standard `tsc` to run type checking. Since "compiling a TypeScript file requires compiling all its dependencies (imports)", **they need to fix files in a specific order: from the leaves of the dependency tree**. This requires additional work and is not practical to fix alongside feature development.

### Output parsing
With [tsc-output-parser](https://github.com/Aiven-Open/tsc-output-parser), `tsc --strict --noEmit | tsc-output-parser` can parse the output of `tsc` to extract type errors.

This approach enables type checking with `tsc` while maintaining a `knownErrors.json` to track and incrementally fix known errors.

```ts
// typecheck.js
const knownErrors = JSON.parse(fs.readFileSync(path.join(__dirname, "knownErrors.json"), "utf8"))

let hasErrors = false
try {
    execSync(`tsc --strict --noEmit`, { stdio: "pipe" })
} catch (error) {
    const output = error.stdout?.toString() || error.toString()
    const parsedOutput = parse(output)
    const remainingErrors = parsedOutput.filter((item) => {
        // filter out the known errors
        return !knownErrors.some((knownError) => knownError.file === item.value.path.value && knownError.code === item.value.tsError.value.errorString)
    })

    if (remainingErrors.length > 0) {
        throw new Error(`Type errors found!`)
    }
}

process.exit(hasErrors ? 1 : 0)
```


### [Stricter TypeScript compilation with Betterer](https://dev.to/phenomnominal/stricter-typescript-compilation-with-betterer-dp7)
Betterer is a test runner that helps make incremental improvements to your code! It is based upon Jest's snapshot testing, but with a twist...
