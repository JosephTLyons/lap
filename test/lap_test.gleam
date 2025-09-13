import birdie
import gleam/time/duration
import gleam/time/timestamp
import gleeunit
import lap

pub fn main() {
  gleeunit.main()
}

pub fn no_lap_test() {
  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.Millisecond, time)

  assert lap.to_list(data) == []
  assert lap.total_time(data) == 0

  data
  |> lap.pretty_print
  |> birdie.snap(title: "Pretty print empty table test")
}

pub fn multiple_lap_test() {
  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.Millisecond, time)

  assert lap.total_time(data) == 0

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.030Z")
  let data = data |> lap.time_with_time("2", time)

  assert lap.total_time(data) == 30

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.040Z")
  let data = data |> lap.time_with_time("3", time)

  assert lap.total_time(data) == 40

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.060Z")
  let data = data |> lap.time_with_time("4", time)

  assert lap.total_time(data) == 60

  assert lap.to_list(data)
    == [#("1", "2", 30), #("2", "3", 10), #("3", "4", 20)]

  assert data
    |> lap.sort_max
    |> lap.to_list
    == [#("1", "2", 30), #("3", "4", 20), #("2", "3", 10)]
}

pub fn pretty_print_test() {
  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.Millisecond, time)

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.030Z")
  let data = data |> lap.time_with_time("2", time)

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.040Z")
  let data = data |> lap.time_with_time("3", time)

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.060Z")
  let data = data |> lap.time_with_time("4", time)

  data
  |> lap.pretty_print
  |> birdie.snap(title: "Pretty print test")
}

pub fn pretty_print_sort_max_test() {
  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.Millisecond, time)

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.030Z")
  let data = data |> lap.time_with_time("2", time)

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.040Z")
  let data = data |> lap.time_with_time("3", time)

  let assert Ok(time) = timestamp.parse_rfc3339("1990-04-12T00:00:00.060Z")
  let data = data |> lap.time_with_time("4", time)

  data
  |> lap.sort_max
  |> lap.pretty_print
  |> birdie.snap(title: "Pretty print sort max test")
}
