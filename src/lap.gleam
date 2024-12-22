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
  IntervalData(start_marker: String, end_marker: String, duration: Int)
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
        birl.difference(time, data.last_time)
          |> duration.blur_to(data.duration_unit),
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

pub fn sort_max(data: LapData) -> LapData {
  // We sort in ascending order because calling `intervals` reverses the order
  // of the list
  let intervals =
    data.intervals
    |> list.sort(fn(a, b) { int.compare(a.duration, b.duration) })

  LapData(..data, intervals: intervals)
}

pub fn intervals(data: LapData) -> List(IntervalTuple) {
  data.intervals
  |> list.map(fn(interval) {
    #(interval.start_marker, interval.end_marker, interval.duration)
  })
  |> list.reverse
}

pub fn pretty_print(data: LapData) -> String {
  let duration_unit_label = duration_unit_label(data.duration_unit)

  let builder =
    tobble.builder()
    |> tobble.add_row(["Start", "End", "Interval"])

  let table =
    data
    |> intervals
    |> list.fold(builder, fn(builder, interval) {
      builder
      |> tobble.add_row([
        interval.0,
        interval.1,
        { interval.2 |> int.to_string } <> " " <> duration_unit_label,
      ])
    })
    |> tobble.build

  case table {
    Ok(table) -> table |> tobble.render
    Error(_) -> ""
  }
}

fn duration_unit_label(duration_unit: Unit) -> String {
  case duration_unit {
    duration.MicroSecond -> "μs"
    duration.MilliSecond -> "ms"
    duration.Second -> "s"
    duration.Minute -> "min"
    duration.Hour -> "h"
    duration.Day -> "d"
    duration.Week -> "w"
    duration.Month -> "mo"
    duration.Year -> "y"
  }
}
