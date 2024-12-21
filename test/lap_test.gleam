import birl
import birl/duration
import gleeunit
import gleeunit/should
import lap

pub fn main() {
  gleeunit.main()
}

pub fn no_lap_test() {
  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.MilliSecond, time)

  data
  |> lap.intervals
  |> should.equal([])
}

pub fn multiple_lap_test() {
  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.MilliSecond, time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.010Z")
  let data = data |> lap.time_with_time("2", time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.020Z")
  let data = data |> lap.time_with_time("3", time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.030Z")
  let data = data |> lap.time_with_time("4", time)

  data
  |> lap.intervals
  |> should.equal([#("1", "2", 10), #("2", "3", 10), #("3", "4", 10)])
}
