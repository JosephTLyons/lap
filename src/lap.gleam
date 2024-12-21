import birl.{type Time}
import birl/duration.{type Unit}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn main() {
  let data = start_in_milliseconds("1")

  // Some work

  let data = data |> lap("2")

  // Some work

  data |> lap("3") |> intervals |> io.debug
}

pub opaque type LapData {
  LapData(
    time: Time,
    marker: String,
    duration_unit: Unit,
    intervals: List(IntervalData),
  )
}

pub opaque type IntervalData {
  IntervalData(
    start_marker: String,
    end_marker: String,
    duration: duration.Duration,
  )
}

pub fn start_in_microseconds(marker: String) -> LapData {
  start(marker, duration.MicroSecond)
}

pub fn start_in_milliseconds(marker: String) -> LapData {
  start(marker, duration.MilliSecond)
}

pub fn start_in_seconds(marker: String) -> LapData {
  start(marker, duration.Second)
}

pub fn start_in_minutes(marker: String) -> LapData {
  start(marker, duration.Minute)
}

pub fn start(marker: String, duration_unit: Unit) -> LapData {
  // Warmup - I noticed in my testing that the first interval was always
  // slightly longer than the others and that by calling birl.now, the intervals
  // are more consistent.
  list.repeat(birl.now(), 3)
  start_with_time(marker, duration_unit, birl.now())
}

@internal
pub fn start_with_time(
  marker: String,
  duration_unit: Unit,
  time: Time,
) -> LapData {
  LapData(time:, marker:, duration_unit:, intervals: [])
}

pub fn lap(data: LapData, marker: String) -> LapData {
  lap_with_time(data, marker, birl.now())
}

@internal
pub fn lap_with_time(data: LapData, marker: String, time: Time) -> LapData {
  let #(start_marker, end_marker) = case data.intervals {
    [] -> #(data.marker, marker)
    [last_interval, ..] -> #(last_interval.end_marker, marker)
  }

  LapData(
    ..data,
    time:,
    intervals: [
      IntervalData(start_marker, end_marker, birl.difference(time, data.time)),
      ..data.intervals
    ],
  )
}

pub fn intervals(data: LapData) -> List(#(String, String, Int)) {
  data.intervals
  |> list.map(fn(interval) {
    #(
      interval.start_marker,
      interval.end_marker,
      interval.duration |> duration.blur_to(data.duration_unit),
    )
  })
  |> list.reverse
}

pub fn pretty_print(data: LapData) -> String {
  let interval_string = fn(interval: #(String, String, Int)) {
    interval.0 <> " - " <> interval.1 <> ": " <> { interval.2 |> int.to_string }
  }

  data
  |> intervals
  |> list.map(interval_string)
  |> string.join("\n")
}
// TODO: Docs
// TODO: TOML
// TODO: README.md
// TODO: Publish
// TODO: lap() name
