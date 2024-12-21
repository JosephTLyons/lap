import birl.{type Time}
import birl/duration.{type Unit}
import gleam/int
import gleam/list
import tobble

pub opaque type LapData {
  LapData(
    first_marker: String,
    first_time: Time,
    last_time: Time,
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

type IntervalTuple =
  #(String, String, Int)

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
  LapData(
    first_marker: marker,
    first_time: time,
    last_time: time,
    duration_unit:,
    intervals: [],
  )
}

pub fn time(data: LapData, marker: String) -> LapData {
  time_with_time(data, marker, birl.now())
}

@internal
pub fn time_with_time(data: LapData, marker: String, time: Time) -> LapData {
  let #(start_marker, end_marker) = case data.intervals {
    [] -> #(data.first_marker, marker)
    [previous_interval, ..] -> #(previous_interval.end_marker, marker)
  }

  LapData(
    ..data,
    last_time: time,
    intervals: [
      IntervalData(
        start_marker,
        end_marker,
        birl.difference(time, data.last_time),
      ),
      ..data.intervals
    ],
  )
}

pub fn total_time(data: LapData) -> Int {
  data.last_time
  |> birl.difference(data.first_time)
  |> duration.blur_to(data.duration_unit)
}

pub fn intervals(data: LapData) -> List(IntervalTuple) {
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

pub fn sort_max(interval_list: List(IntervalTuple)) -> List(IntervalTuple) {
  interval_list |> list.sort(fn(a, b) { int.compare(b.2, a.2) })
}

pub fn pretty_print(interval_list: List(IntervalTuple)) -> String {
  let table =
    tobble.builder()
    |> tobble.add_row(["Start", "End", "Interval"])

  let table =
    interval_list
    |> list.fold(table, fn(builder, interval) {
      builder
      |> tobble.add_row([
        interval.0,
        interval.1,
        { interval.2 |> int.to_string },
      ])
    })
    |> tobble.build()

  case table {
    Ok(table) -> table |> tobble.render
    Error(_) -> ""
  }
}
