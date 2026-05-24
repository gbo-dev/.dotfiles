#!/bin/sh
# Usage: hyprlock-digit.sh <format> <cut>
# e.g.   hyprlock-digit.sh '%H' 1   -> first digit of hours
# Outputs a Pango span with tnum + ROND=100 wrapping the digit
digit=$(date +"$1" | cut -c"$2")
printf '<span font-variations="ROND 100" font-features="tnum">%s</span>\n' "$digit"
