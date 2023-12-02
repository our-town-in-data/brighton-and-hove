#!/bin/bash
# dir="$HOME/workspaces/personal/our-town-in-data/brighton-and-hove/sea/weather/bin"
# project_dir="$HOME/workspaces/personal/our-town-in-data/scripts/output"
set -e

# Orientation.
dir=$(dirname "$0")
project_dir=$(cd "$dir/../../.." && pwd)

# Set the input and output files, and directories
live_data="$project_dir/sea/weather/live/sample.json"
csv_dir="$project_dir/sea/weather/csv"
filename="weather.csv"

# Detect errors, aborting if necessary.
error=$(cat "$live_data" | jq '.error')
if [[ "$error" != "null" ]] ; then
    echo "Error: $error"
    exit 0
fi

# Find the date
date_string=$(cat "$live_data" | jq -r '.meta.start')
year="${date_string%%-*}"
month="${date_string#*-}"
month="${month%%-*}"
day="${date_string%% *}"
day="${day##*-}"

write_to_csv() {
    local csv="$2"
    local live_data="$1"$liv

    local directory=$(dirname "$csv")
    mkdir -p "$directory"

    if [[ ! -f "$csv" ]] ; then
        echo "Date and Time, Water Temperature, Wind Speed, Wind Direction, Gust, Wave Height, Wave Direction, Wave Period, Visibility, Direction of Current, Speed of Current, Air Temperature" > "$csv"
    fi

    cat "$live_data" | jq -r '
    (.hours[] | [.time, .waterTemperature.sg, .windSpeed.sg, .windDirection.sg, .gust.sg, .waveHeight.sg, .waveDirection.sg, .wavePeriod.sg, .visibility.sg, .currentDirection.sg, .currentSpeed.sg, .airTemperature.sg])
    | @csv' >> "$csv"
}

write_to_csv "$live_data" "$csv_dir/historical/$filename"
write_to_csv "$live_data" "$csv_dir/by-year/$year/$filename"
write_to_csv "$live_data" "$csv_dir/by-month/$year/$month/$filename"
write_to_csv "$live_data" "$csv_dir/by-day/$year/$month/$day/$filename"

today="$csv_dir/today"
mkdir -p "$today"
cp "$csv_dir/by-day/$year/$month/$day/$filename" "$today/$filename"
