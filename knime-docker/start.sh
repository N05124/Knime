#!/usr/bin/env bash
set -Eeuo pipefail

export DISPLAY=:99
export XDG_RUNTIME_DIR=/tmp/runtime-knime
export NO_AT_BRIDGE=1
export LIBGL_ALWAYS_SOFTWARE=1

mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Clear stale X lock/socket left over when the container is restarted (not recreated);
# otherwise Xvfb refuses to start and KNIME fails with "Cannot open display".
rm -f /tmp/.X99-lock /tmp/.X11-unix/X99

echo "Starting Xvfb..."
Xvfb :99 -screen 0 1600x900x24 \
  -nolisten tcp -ac \
  > /tmp/xvfb.log 2>&1 &
XVFB_PID=$!

echo "Waiting for virtual display..."
READY=0

for i in $(seq 1 30); do
  if ! kill -0 "$XVFB_PID" 2>/dev/null; then
    echo "ERROR: Xvfb exited."
    cat /tmp/xvfb.log
    exit 1
  fi

  if [ -S /tmp/.X11-unix/X99 ]; then
    READY=1
    break
  fi

  sleep 1
done

if [ "$READY" -ne 1 ]; then
  echo "ERROR: Xvfb display not ready."
  cat /tmp/xvfb.log
  exit 1
fi

echo "Starting XFCE..."
xfce4-session > /tmp/xfce.log 2>&1 &

echo "Starting VNC..."
x11vnc -display :99 \
  -localhost -forever -shared -nopw \
  -rfbport 5900 \
  > /tmp/vnc.log 2>&1 &

echo "Starting noVNC..."
websockify --web=/usr/share/novnc/ \
  0.0.0.0:6080 localhost:5900 \
  > /tmp/novnc.log 2>&1 &

echo "Starting KNIME..."
exec /opt/knime/knime \
  -data /home/knime/workspace \
  -consoleLog
