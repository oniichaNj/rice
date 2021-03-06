#!/bin/sh

# Find the line in "xrandr -q --verbose" output that contains current screen orientation and "strip" out current orientation.

rotation="$(xrandr -q --verbose | grep 'connected' | egrep -o  '\) (normal|left|inverted|right) \(' | egrep -o '(normal|left|inverted|right)')"

# Using current screen orientation proceed to rotate screen and input tools.

case "$rotation" in
    normal)
	# rotate to the left
	xrandr -o left
	xsetwacom set "Serial Wacom Tablet WACf004 stylus" rotate ccw
	xsetwacom set "Serial Wacom Tablet WACf004 eraser" rotate ccw
	;;
    left)
	# rotate to normal
	xrandr -o normal
	xsetwacom set "Serial Wacom Tablet WACf004 stylus" rotate none
	xsetwacom set "Serial Wacom Tablet WACf004 eraser" rotate none
	;; 
esac
