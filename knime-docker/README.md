# KNIME Analytics Platform in Docker

This is a Linux amd64 GUI container using Ubuntu 22.04, XFCE, Xvfb, noVNC and the official KNIME Linux archive. It is intended for **local development only**. The VNC service has no password but is bound to localhost inside the container; noVNC is published to the host only at 127.0.0.1:6080. Do not expose the port publicly.

## Start

```bash
mkdir -p workspace data
docker compose up --build -d
```

Open http://localhost:6080/vnc.html and click Connect. Allow several minutes for the first build and KNIME startup.

## Stop / inspect

```bash
docker compose down
docker compose logs -f knime
```

Your workflows persist under `./workspace`, and data under `./data`. The host directories should be writable by UID 1000 (the container user); adjust permissions if necessary.

## Apple Silicon

The official archive in this configuration is Linux x86_64. Docker Desktop will emulate it on Apple Silicon, which can be substantially slower. Docker Desktop should be given at least 8 GiB of memory for the configured container limit.

## Limitations

This is a KNIME desktop GUI over noVNC, **not** KNIME Business Hub or a browser-native KNIME editor. Python 3 is installed but KNIME Python integration may require installing/configuring KNIME extensions and environments inside the container. Rebuilding against the `latest` archive can change the installed version; pin a tested archive URL for reproducibility.

## macOS one-click launcher

Double-click `launch.command` in Finder. It checks whether the Docker engine is running, opens Docker Desktop if needed, waits up to three minutes, starts the KNIME Compose service (building the image when needed), and opens the browser desktop once reachable. Docker Desktop will not be set to start automatically at login.

If macOS blocks the downloaded script, right-click it and choose **Open**, or run `bash launch.command` from Terminal inside this folder. If necessary, run `chmod +x launch.command` once. The launcher keeps the Terminal window open so startup errors remain visible.

## Apple Silicon fixes (2026-11-16)

Verified working on an Apple Silicon Mac (Docker Desktop with Rosetta). The Dockerfile now:
- starts KNIME's embedded Chromium with `--no-sandbox --disable-gpu --disable-crash-reporter` (it segfaulted under Rosetta otherwise),
- keeps Chromium's cache inside the container (`-Dchromium.cache_path`) instead of `workspace/.metadata`, where a stale cache caused crashes,
- makes `/opt/knime/bundling` writable so KNIME can set up its bundled Python environments.

`start.sh` also clears stale X display locks, so the container survives restarts.
First start takes about 1–2 minutes before the KNIME window appears.
