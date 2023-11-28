#! /bin/sh

max_attempts=5
attempt=1

while [ $attempt -le $max_attempts ]; do
    Xvfb :99 -ac -listen tcp -screen 0 1225x945x16 &
    export DISPLAY=:99
    sleep 3

    # Проверяем, запустился ли Xvfb
    if [ -n "$(pgrep Xvfb)" ]; then
        break
    fi

    echo "Попытка $attempt запуска Xvfb не удалась"
    attempt=$((attempt + 1))
done

if [ $attempt -gt $max_attempts ]; then
    echo "Не удалось запустить Xvfb после $max_attempts попыток"
    exit 1
fi

/usr/bin/fluxbox -display :99 -screen 0 &

#export LOG_LEVEL=debug

if [ "$VNC_PASSWORD" = "none" ]; then
  x11vnc -display :99.0 -forever &
else
  x11vnc -display :99.0 -forever -passwd $VNC_PASSWORD &
fi
supervisord &&

/usr/bin/python3 -u /app/flaresolverr/flaresolverr.py
