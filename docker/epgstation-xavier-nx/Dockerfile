FROM nvcr.io/nvidia/l4t-base:r35.1.0 AS base
RUN apt-get update \
 && apt-get install -y git curl npm \
 && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get install -y nodejs \
 && git clone https://github.com/l3tnun/EPGStation.git /app

FROM base AS client-builder
WORKDIR /app/client
RUN npm install --no-save --log-level=info \
 && npm run build --loglevel=info

FROM base AS server-builder
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER="YES"
WORKDIR /app
RUN apt-get install -y build-essential python3 \
 && npm install --no-save --loglevel=info \
 && rm -rf client \
 && npm run build-server --loglevel=info

FROM nvcr.io/nvidia/l4t-jetpack:r35.1.0 AS ffmpeg-builder
WORKDIR /opt
RUN apt-get update \
 && apt-get install -y autoconf automake build-essential cmake git libaom-dev libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libtool libunistring-dev libvorbis-dev meson ninja-build pkg-config texinfo wget yasm zlib1g-dev
RUN git clone https://github.com/KeyLost/jetson-ffmpeg.git \
 && cd jetson-ffmpeg \
 && mkdir build \
 && cd build \
 && cmake .. \
 && sed -i -E 's#^(Libs:.+)$#\1 -L/usr/lib/aarch64-linux-gnu/tegra -lnvbufsurface#g' nvmpi.pc \
 && make \
 && make install \
 && ldconfig
RUN git clone git://source.ffmpeg.org/ffmpeg.git -b release/6.0 --depth=1 \
 && cd ffmpeg \
 && wget -O ffmpeg_nvmpi.patch https://github.com/Keylost/jetson-ffmpeg/raw/master/ffmpeg_patches/ffmpeg6.0_nvmpi.patch \
 && git apply ffmpeg_nvmpi.patch \
 && ./configure --enable-nvmpi \
 && make

FROM base AS artefact
# Copy server
COPY --from=server-builder /app /app
# Copy Client
COPY --from=client-builder /app/client /app/client/
# Copy ffmpeg files
COPY --from=ffmpeg-builder /usr/local/lib/* /usr/local/lib/
COPY --from=ffmpeg-builder /usr/local/include/* /usr/local/include/
COPY --from=ffmpeg-builder /usr/local/share/* /usr/local/share/
COPY --from=ffmpeg-builder /opt/ffmpeg /opt/ffmpeg
# Install ffmpeg
WORKDIR /opt/ffmpeg
RUN make install
# Clean up
RUN apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
EXPOSE 8888
WORKDIR /app
CMD ["/bin/bash"]
