# lap

[![Package Version](https://img.shields.io/hexpm/v/lap)](https://hex.pm/packages/lap)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lap/)

```sh
gleam add lap
```
```gleam
import lap
import gleam/io

pub fn main() {
  let data = lap.start_in_milliseconds("1")

  // Some work

  let data = data |> lap.lap("2")

  // Some work

  data |> lap.lap("3") |> lap.intervals |> io.debug
  // [#("1", "2", 10), #("2", "3", 30)]
}
```
