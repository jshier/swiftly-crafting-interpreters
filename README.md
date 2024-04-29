### A Swift Exploration of Crafting Interpreters

This repo tracks my progress in reading and implementing the Lox language from [*Crafting Interpreters*](https://www.amazon.com/Crafting-Interpreters-Robert-Nystrom/dp/0990582930).

There are two main (eventual) components:

- `slox`: command line tool for interpreting lox files.
- `SloxKit`: library which implements the interpreter.

There may eventually be more libraries for the different bits. In addition to the implementation itself, there will be a suite of benchmarks under the `slox-bench` directory, so I can compare various implementations more precisely.
