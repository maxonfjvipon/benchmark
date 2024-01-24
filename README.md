<img alt="logo" src="https://www.objectionary.com/cactus.svg" height="100px" />

[![EO principles respected here](https://www.elegantobjects.org/badge.svg)](https://www.elegantobjects.org)
[![DevOps By Rultor.com](http://www.rultor.com/b/objectionary/eo)](http://www.rultor.com/p/objectionary/eo)
[![We recommend IntelliJ IDEA](https://www.elegantobjects.org/intellij-idea.svg)](https://www.jetbrains.com/idea/)

[![mvn](https://github.com/objectionary/benchmark/actions/workflows/mvn.yml/badge.svg)](https://github.com/objectionary/benchmark/actions/workflows/mvn.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.txt)

It's a benchmark that puts together:

  * [jeo-maven-plugin](https://github.com/objectionary/jeo-maven-plugin)
  * [opeo-maven-plugin](https://github.com/objectionary/opeo-maven-plugin)
  * [ineo-maven-plugin](https://github.com/objectionary/ineo-maven-plugin)

The goal is to test the performance of Java code before optimization and after,
then comparing the results. Intermediate artifacts are in this 
[`summary.html`](https://www.objectionary.com/benchmark/summary.html).

<!-- benchmark -->
This is the summary of the tests performed with the TOTAL set to 100000000, at 2024-01-24 07:40, on Linux, with 4 CPUs:

| | Before | After |
| --- | --: | --: |
| Time (with JIT) | 3.24 | 3.22 |
| Time (no JIT) | 11.76 | 7.89 |
| Files | 5 | 6 |
| Bytes | 6500 | 5834 |

This table is updated on every successful run of the [make](https://github.com/objectionary/benchmark/actions/workflows/make.yml) job of GitHub Actions.

<!-- benchmark -->


## How to Contribute

Fork repository, make changes, then send us
a [pull request](https://www.yegor256.com/2014/04/15/github-guidelines.html).
We will review your changes and apply them to the `master` branch shortly,
provided they don't violate our quality standards. To avoid frustration,
before sending us your pull request please run full build:

```bash
$ make
```

You will need [Maven 3.3+](https://maven.apache.org) and Java 11+ installed.

