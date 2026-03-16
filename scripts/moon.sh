#!/bin/bash
# A simple script to get current moon phase emoji
get_moon_icon () {
    local lp=2551443
    local now=$(date +%s)
    local newmoon=592500 # Approximate epoch for a new moon
    local phase=$((($now - $newmoon) % $lp))
    local phase_day=$(((phase / 86400) + 1))

    if [ $phase_day -lt 2 ];  then echo "🌑"; # New Moon
    elif [ $phase_day -lt 7 ];  then echo "🌒"; # Waxing Crescent
    elif [ $phase_day -lt 10 ]; then echo "🌓"; # First Quarter
    elif [ $phase_day -lt 15 ]; then echo "🌔"; # Waxing Gibbous
    elif [ $phase_day -lt 17 ]; then echo "🌕"; # Full Moon
    elif [ $phase_day -lt 22 ]; then echo "🌖"; # Waning Gibbous
    elif [ $phase_day -lt 25 ]; then echo "🌗"; # Last Quarter
    else echo "🌘"; # Waning Crescent
    fi
}
get_moon_icon