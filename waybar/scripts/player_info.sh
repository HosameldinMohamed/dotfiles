#!/bin/bash

format_time() {
	local total_seconds=$1
	printf "%02d:%02d" "$((total_seconds / 60))" "$((total_seconds % 60))"
}

truncate_text() {
	local text="$1"
	local max_len=$2

	if (( max_len <= 0 )); then
		echo ""
		return
	fi

	if (( ${#text} > max_len )); then
		if (( max_len <= 3 )); then
			echo "${text:0:max_len}"
		else
			echo "${text:0:$((max_len - 3))}..."
		fi
	else
		echo "$text"
	fi
}

json_escape() {
	local s="$1"
	s=${s//\\/\\\\}
	s=${s//\"/\\\"}
	s=${s//$'\n'/\\n}
	s=${s//$'\r'/}
	echo "$s"
}

PLAYERS=$(playerctl -l 2>/dev/null | grep -v '^playerctld$')
[[ -z "$PLAYERS" ]] && exit 0

PLAYER_NAME="$(playerctl metadata --format "{{playerName}}" 2>/dev/null)"
[[ -z "$PLAYER_NAME" ]] && PLAYER_NAME="player"

TITLE="$(playerctl metadata --format "{{title}}" 2>/dev/null)"
ARTIST="$(playerctl metadata --format "{{artist}}" 2>/dev/null)"

if [[ -n "$TITLE" && -n "$ARTIST" ]]; then
	TRACK="$TITLE - $ARTIST"
elif [[ -n "$TITLE" ]]; then
	TRACK="$TITLE"
elif [[ -n "$ARTIST" ]]; then
	TRACK="$ARTIST"
else
	TRACK="No track"
fi

POS_RAW="$(playerctl position 2>/dev/null | cut -d'.' -f1)"
POS_SEC=${POS_RAW:-0}
ELAPSED="$(format_time "$POS_SEC")"
LEN_RAW="$(playerctl metadata mpris:length 2>/dev/null)"

if [[ -n "$LEN_RAW" && "$LEN_RAW" -gt 0 ]]; then
	TOTAL_SEC=$((LEN_RAW / 1000000))
	TOTAL="$(format_time "$TOTAL_SEC")"
else
	TOTAL="--:--"
fi

MAX_LINE_LENGTH=${MAX_LINE_LENGTH:-50}
TIME_STR="$ELAPSED/$TOTAL"
PREFIX="$PLAYER_NAME | "
SUFFIX=" | $TIME_STR"

AVAILABLE_TRACK_LEN=$((MAX_LINE_LENGTH - ${#PREFIX} - ${#SUFFIX}))
TRACK_DISPLAY="$(truncate_text "$TRACK" "$AVAILABLE_TRACK_LEN")"
DISPLAY_TEXT="$TRACK_DISPLAY$SUFFIX"
FULL_TEXT="$PREFIX$TRACK$SUFFIX"

printf '{"text":"%s","tooltip":"%s"}\n' \
	"$(json_escape "$DISPLAY_TEXT")" \
	"$(json_escape "$FULL_TEXT")"

