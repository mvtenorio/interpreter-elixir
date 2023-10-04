Simple interpreter written in Elixir based on [this series of articles](https://ruslanspivak.com/lsbasi-part1/)

### Grammar
```
expr: (+|-) term (+|- term)*
term: factor (*|/ factor)*
factor: INTEGER
```
