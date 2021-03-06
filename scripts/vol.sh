#!/bin/bash

case "$1" in
    raise)
	# increase volume
	amixer -q sset 'Master' 2%+
	volnoti-show `awk -F"[][]" '/dB/ { print $2 }' <(amixer sget Master)`
	;;
    lower)
	# lower volume
	amixer -q sset 'Master' 2%-
	volnoti-show `awk -F"[][]" '/dB/ { print $2 }' <(amixer sget Master)`
	;; 
    mute)
	# mute
	amixer -q sset 'Master' 0%
	volnoti-show -m
esac
