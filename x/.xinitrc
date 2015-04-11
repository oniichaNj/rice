#!/bin/sh

#go swede
setxkbmap se

#fonts
xset fp+ /home/user/.fonts
xset fp rehash

#LEET
dwmstatus &

# MOAR RICE
compton --config ~/.compton.conf -b --vsync opengl

#apply dem smexy colors
xrdb -merge ~/.Xresources

# Screen Locker
#xautolock -time 5 -locker slock -nowlocker slock -detectsleep -corners 000+ -cornerdelay 3 &

#SNAKE OIL EYE IMPROVEMENT
redshift -l 56.14:13.55 -t 6500K:4200K &

#we need a god damn fogs as a wallpaper. Why? Because FUCK YOU, that's why
feh --bg-fill /home/user/images/wallpaper/sl.jpg

#Cryptos n shiz.
eval "$(gpg-agent --daemon)"

#Gotta map dem keys.
xbindkeys

#fancy shit
volnoti

# Fixing keyboard delay and repetition rate.
xset r rate 300 25 

#and why the fuck aren't YOU using dwm?
#Oh, and dmenu is nice ^______^
dwm >/dev/null 2>&1
dmenu_run &

#no EOF here fuck you
