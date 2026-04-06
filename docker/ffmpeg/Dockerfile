FROM nvcr.io/nvidia/l4t-jetpack:r35.4.1

WORKDIR /opt

ARG INSTALL_PREFIX=/rootfs/usr/local
ARG FFMPEG_VERSION=8.0

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential clang cmake pkg-config curl git

RUN curl -sfkL -o jetson_multimedia_api.tbz2  https://developer.nvidia.com/embedded/L4T/r35_release_v6.4/Release/Jetson_Multimedia_API_R35.6.4_aarch64.tbz2 \
 && mkdir -p /root/build_deps/jetson_multimedia_api \
 && tar xaf jetson_multimedia_api.tbz2 -C /root/build_deps/jetson_multimedia_api

RUN git clone https://github.com/Keylost/jetson-ffmpeg.git \
 && cd jetson-ffmpeg \
 && LD_LIBRARY_PATH=$(pwd)/stubs:$LD_LIBRARY_PATH \
 && mkdir build \
 && cd build \
 && cmake -DWITH_STUBS=ON -DJETSON_MULTIMEDIA_API_DIR=/root/build_deps/jetson_multimedia_api/usr/src/jetson_multimedia_api -DCMAKE_BUILD_TYPE=ReleaseWithDebInfo -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX .. \
 && make -j$(nproc) \
 && make install

RUN git clone https://github.com/FFmpeg/nv-codec-headers \
 && cd nv-codec-headers \
 && make install \
 && cd ..

RUN git clone git://source.ffmpeg.org/ffmpeg.git -b release/$FFMPEG_VERSION --depth=1 \
 && cd jetson-ffmpeg \
 && ./ffpatch.sh ../ffmpeg

# RUN cd ffmpeg \
#  && export PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig \
#  && ./configure --enable-nvmpi --enable-ffnvcodec --enable-cuda-llvm \
#             --disable-cuvid --disable-nvenc --disable-nvdec \
#             --enable-shared --disable-static --prefix=$INSTALL_PREFIX \
#  && make -j$(nproc) \
#  && make install
