FROM nvcr.io/nvidia/l4t-base:r35.1.0 AS common-base
RUN apt-get update \
 && apt-get install -y git curl npm \
 && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
 && apt-get install -y nodejs \
 && git clone https://github.com/l3tnun/EPGStation.git /app

FROM common-base AS client-builder
WORKDIR /app/client
RUN npm install --no-save --log-level=info \
 && npm run build --loglevel=info

FROM common-base AS server-builder
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER="YES"
WORKDIR /app
RUN apt-get install -y build-essential python3 \
 && npm install --no-save --loglevel=info \
 && rm -rf client \
 && npm run build-server --loglevel=info

FROM common-base
WORKDIR /opt
ENV DEV="autoconf automake build-essential cmake libaom-dev libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libtool libunistring-dev libvorbis-dev meson ninja-build pkg-config texinfo wget yasm zlib1g-dev"

RUN apt-get install -y $DEV

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
 && make \
 && make install

RUN apt-get -y remove $DEV \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/*

LABEL maintainer="octarect"
COPY --from=server-builder /app /app
COPY --from=client-builder /app/client /app/client/
EXPOSE 8888
WORKDIR /app
CMD ["/bin/bash"]
