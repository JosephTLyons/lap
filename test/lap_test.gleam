import birdie
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

  data
  |> lap.total_time
  |> should.equal(0)
}

pub fn multiple_lap_test() {
  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.MilliSecond, time)

  data |> lap.total_time |> should.equal(0)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.030Z")
  let data = data |> lap.time_with_time("2", time)

  data |> lap.total_time |> should.equal(30)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.040Z")
  let data = data |> lap.time_with_time("3", time)

  data |> lap.total_time |> should.equal(40)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.060Z")
  let data = data |> lap.time_with_time("4", time)

  data |> lap.total_time |> should.equal(60)

  data
  |> lap.intervals
  |> should.equal([#("1", "2", 30), #("2", "3", 10), #("3", "4", 20)])

  data
  |> lap.sort_max
  |> lap.intervals
  |> should.equal([#("1", "2", 30), #("3", "4", 20), #("2", "3", 10)])
}

pub fn pretty_print_test() {
  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.MilliSecond, time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.030Z")
  let data = data |> lap.time_with_time("2", time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.040Z")
  let data = data |> lap.time_with_time("3", time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.060Z")
  let data = data |> lap.time_with_time("4", time)

  data
  |> lap.pretty_print
  |> birdie.snap(title: "Pretty print test")
}

pub fn pretty_print_sort_max_test() {
  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.000Z")
  let data = lap.start_with_time("1", duration.MilliSecond, time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.030Z")
  let data = data |> lap.time_with_time("2", time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.040Z")
  let data = data |> lap.time_with_time("3", time)

  let assert Ok(time) = birl.parse("1990-04-12T00:00:00.060Z")
  let data = data |> lap.time_with_time("4", time)

  data
  |> lap.sort_max
  |> lap.pretty_print
  |> birdie.snap(title: "Pretty print sort max test")
}
