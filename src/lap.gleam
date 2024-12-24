import birl.{type Time}
import birl/duration.{type Unit}
import gleam/float
import gleam/int
import gleam/list
import tobble

pub opaque type LapData {
  LapData(
    first_marker: String,
    first_time: Time,
    last_time: Time,
    duration_unit: Unit,
    durations: List(DurationData),
  )
}

pub opaque type DurationData {
  DurationData(start_marker: String, end_marker: String, value: Int)
}

type DurationTuple =
  #(String, String, Int)

/// Begins a new timing session with the given marker and duration unit in
/// microseconds.
pub fn start_in_microseconds(marker: String) -> LapData {
  start(marker, duration.MicroSecond)
}

/// Begins a new timing session with the given marker and duration unit in
/// milliseconds.
pub fn start_in_milliseconds(marker: String) -> LapData {
  start(marker, duration.MilliSecond)
}

/// Begins a new timing session with the given marker and duration unit in
/// seconds.
pub fn start_in_seconds(marker: String) -> LapData {
  start(marker, duration.Second)
}

/// Begins a new timing session with the given marker and duration unit in
/// minutes.
pub fn start_in_minutes(marker: String) -> LapData {
  start(marker, duration.Minute)
}

/// Begins a new timing session with the given marker and duration unit. The
/// duration_unit is a [birl](https://hexdocs.pm/birl/) `Unit`.
pub fn start(marker: String, duration_unit: Unit) -> LapData {
  // Warmup - I noticed in my testing that the first duration was always
  // slightly longer than the others and that by calling birl.now, the durations
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
    durations: [],
  )
}

/// Marks the end of the current lap with the given marker.
pub fn time(data: LapData, marker: String) -> LapData {
  time_with_time(data, marker, birl.now())
}

@internal
pub fn time_with_time(data: LapData, marker: String, time: Time) -> LapData {
  let #(start_marker, end_marker) = case data.durations {
    [] -> #(data.first_marker, marker)
    [previous_duration, ..] -> #(previous_duration.end_marker, marker)
  }

  LapData(
    ..data,
    last_time: time,
    durations: [
      DurationData(
        start_marker,
        end_marker,
        birl.difference(time, data.last_time)
          |> duration.blur_to(data.duration_unit),
      ),
      ..data.durations
    ],
  )
}

/// Returns the total time elapsed from the first marker to the last marker, in
/// the duration unit specified via one of the start functions.
pub fn total_time(data: LapData) -> Int {
  data.last_time
  |> birl.difference(data.first_time)
  |> duration.blur_to(data.duration_unit)
}

/// Sorts the durations in descending order. This is useful for identifying the
/// slowest parts of your timed code.
pub fn sort_max(data: LapData) -> LapData {
  // We sort in ascending order because calling `to_list` reverses the order
  // of the list
  let durations =
    data.durations
    |> list.sort(fn(a, b) { int.compare(a.value, b.value) })

  LapData(..data, durations:)
}

/// Return the durations as a list of tuples. Each tuple contains:
/// 1. The start marker (String)
/// 2. The end marker (String)
/// 3. The duration (Int) in the specified time unit
pub fn to_list(data: LapData) -> List(DurationTuple) {
  data.durations
  |> list.map(fn(duration) {
    #(duration.start_marker, duration.end_marker, duration.value)
  })
  |> list.reverse
}

/// Returns a table of the durations as a string. The table includes the start
/// and end markers, duration, and percentage of the total time.
pub fn pretty_print(data: LapData) -> String {
  let duration_unit_label = duration_unit_label(data.duration_unit)

  let builder =
    tobble.builder()
    |> tobble.add_row(["Start", "End", "Duration", "%"])

  let total_time = total_time(data)

  let builder =
    data
    |> to_list
    |> list.fold(builder, fn(builder, duration) {
      builder
      |> tobble.add_row([
        duration.0,
        duration.1,
        { duration.2 |> int.to_string } <> " " <> duration_unit_label,
        to_rounded_percentage(duration.2, total_time) |> float.to_string,
      ])
    })

  case tobble.build(builder) {
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

fn to_percentage(a: Int, b: Int) -> Float {
  let ratio = int.to_float(a) /. int.to_float(b)
  ratio *. 100.0
}

fn to_rounded_percentage(a: Int, b: Int) -> Float {
  let percentage = to_percentage(a, b)
  {
    { { percentage *. 100.0 } |> float.truncate }
    |> int.to_float
  }
  /. 100.0
}
