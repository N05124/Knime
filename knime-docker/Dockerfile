FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && update-ca-certificates && sed -i 's@http://@https://@g' /etc/apt/sources.list && apt-get update && apt-get install -y --no-install-recommends ca-certificates curl tar python3 python3-pip python3-venv xfce4 xfce4-terminal x11vnc xvfb novnc websockify dbus-x11 libgtk-3-0 libwebkit2gtk-4.0-37 libnss3 libasound2 libgbm1 libxss1 libxtst6 libxrender1 libxi6 libxrandr2 libxinerama1 libgl1 libglu1-mesa fonts-dejavu-core && rm -rf /var/lib/apt/lists/*
ARG KNIME_URL=https://download.knime.com/analytics-platform/linux/knime-full-latest-linux.gtk.x86_64.tar.gz
COPY knime.tar.gz /tmp/knime.tar.gz
RUN mkdir -p /opt/knime && \
    tar -xzf /tmp/knime.tar.gz -C /opt/knime --strip-components=1 && \
    rm /tmp/knime.tar.gz && \
    test -x /opt/knime/knime

RUN useradd -m -u 1000 knime && mkdir -p /home/knime/workspace /home/knime/data && chown -R knime:knime /home/knime

# Apple Silicon fixes (KNIME runs under Rosetta x86 emulation):
# - KNIME's embedded Chromium crashes at startup unless its sandbox, GPU and crash reporter are off.
# - Chromium's cache goes inside the container, not the mounted workspace (a stale cache there made it segfault).
# - KNIME must be able to unpack its bundled Python environments into /opt/knime/bundling.
# - Raise KNIME's Java heap from the default 2 GB (it froze from memory pressure); container limit is 8 GB.
RUN sed -i 's/^-Xmx.*/-Xmx5g/' /opt/knime/knime.ini && \
    echo '-Dchromium.args=--no-sandbox;--disable-gpu;--disable-gpu-compositing;--disable-dev-shm-usage;--disable-crash-reporter;--disable-breakpad' >> /opt/knime/knime.ini && \
    echo '-Dchromium.cache_path=/home/knime/.cache/knime-cef' >> /opt/knime/knime.ini && \
    mkdir -p /opt/knime/bundling && chown knime:knime /opt/knime/bundling

# Ubuntu 22.04's noVNC 1.0.0 (2018) shows only a blank page in some current browsers (e.g. Safari).
# Replace it with a current release; start.sh still serves it from /usr/share/novnc.
ARG NOVNC_VERSION=1.6.0
RUN rm -rf /usr/share/novnc && mkdir -p /usr/share/novnc && \
    curl -fsSL "https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz" \
      | tar -xz -C /usr/share/novnc --strip-components=1 && \
    test -f /usr/share/novnc/vnc.html
COPY start.sh /usr/local/bin/start-knime
RUN chmod +x /usr/local/bin/start-knime
USER knime
ENV HOME=/home/knime DISPLAY=:99
WORKDIR /home/knime
EXPOSE 6080
CMD ["/usr/local/bin/start-knime"]
