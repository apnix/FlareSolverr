#! /bin/sh
Xvfb :99 -ac -listen tcp -screen 0 1210x950x16 &
export DISPLAY=:99
sleep 3
/usr/bin/fluxbox -display :99 -screen 0 &

#x11vnc -display :99.0 -forever -passwd 1563 &
x11vnc -display :99.0 -forever &

/usr/bin/python3 -u /app/flaresolverr/flaresolverr.py
