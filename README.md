# lap

[![Package Version](https://img.shields.io/hexpm/v/lap)](https://hex.pm/packages/lap)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lap/)

Quick'n dirty timing of your Gleam code.

```sh
gleam add lap
```

```gleam
import lap
import gleam/io

pub fn main() {
  let data = lap.start_in_milliseconds("1")

  // Some work

  let data = data |> lap.time("2")

  // Some work

  let data = data |> lap.time("3")

  data |> lap.intervals |> io.debug
  // [#("1", "2", 10), #("2", "3", 30)]

  data |> lap.pretty_print |> io.println
  // +-------+-----+----------+
  // | Start | End | Interval |
  // +-------+-----+----------+
  // | 1     | 2   | 10       |
  // | 2     | 3   | 30       |
  // +-------+-----+----------+
}
```
