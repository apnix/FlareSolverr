#! /bin/sh
Xvfb :99 -ac -listen tcp -screen 0 1225x945x16 &
  export DISPLAY=:99
sleep 3
/usr/bin/fluxbox -display :99 -screen 0 &

if [ "$VNC_PASSWORD" = "none" ]; then
  x11vnc -display :99.0 -forever &
else
  x11vnc -display :99.0 -forever -passwd $VNC_PASSWORD &
fi

/usr/bin/python3 -u /app/flaresolverr/flaresolverr.py
