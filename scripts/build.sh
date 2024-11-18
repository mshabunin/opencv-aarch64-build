#!/bin/bash

set -ex

NCPU=12
VPROTOBUF=v3.18.2
VTBB=v2021.7.0
VFFMPEG=n5.1.2
GITOPT="--depth=1 --recurse-submodules"
CMAKEOPT=(
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_PREFIX=/workspace/install"
    "-DCMAKE_FIND_ROOT_PATH=/workspace/install"
    "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
    "-DCMAKE_C_COMPILER_LAUNCHER=ccache"
)

export PATH=/usr/lib/ccache:${PATH}


#=========================================================

build_protobuf() {
D=/workspace/protobuf
[ -d ${D} ] || git clone ${GITOPT} --branch=${VPROTOBUF} https://github.com/protocolbuffers/protobuf ${D}
pushd ${D}
[ -f configure ] || ./autogen.sh
# for host (protoc)
./configure \
    --prefix=/workspace/host
make -j${NCPU}
make install
make distclean
# for target (lib)
CC=aarch64-linux-gnu-gcc \
CXX=aarch64-linux-gnu-g++ \
./configure \
    --prefix=/workspace/install \
    --without-protoc \
    --host=aarch64 \
    --with-protoc=/workspace/host/bin/protoc \
    --with-pic
make -j${NCPU}
make install
make distclean
popd
}

#=========================================================

build_tbb() {
D=/workspace/oneTBB
[ -d ${D} ] || git clone ${GITOPT} --branch=${VTBB} https://github.com/oneapi-src/oneTBB ${D}
D=/workspace/build-tbb
mkdir -p ${D}
pushd ${D} && rm -rf *
cmake -GNinja \
    ${CMAKEOPT[@]} \
    -DCMAKE_TOOLCHAIN_FILE=/openvino/cmake/arm64.toolchain.cmake \
    -DTBB_TEST=OFF \
    -DTBB_STRICT=OFF \
    /workspace/oneTBB
ninja install
popd
}

#=========================================================

build_openvino() {
D=/workspace/build-openvino
mkdir -p ${D}
pushd ${D} && rm -rf *
CFLAGS=-Wno-narrowing \
CXX=aarch64-linux-gnu-g++ \
PKG_CONFIG_PATH=/workspace/install/lib/pkgconfig \
PKG_CONFIG_LIBDIR=/workspace/install/lib \
cmake -GNinja \
    ${CMAKEOPT[@]} \
    -DCMAKE_TOOLCHAIN_FILE=/openvino/cmake/arm64.toolchain.cmake \
    -DENABLE_OPENCV=OFF \
    -DENABLE_INTEL_MYRIAD_COMMON=OFF \
    -DENABLE_INTEL_MYRIAD=OFF \
    -DENABLE_INTEL_GPU=OFF \
    -DENABLE_INTEL_CPU=OFF \
    -DENABLE_SAMPLES=OFF \
    -DENABLE_SYSTEM_PROTOBUF=ON \
    -DProtobuf_PROTOC_EXECUTABLE=/workspace/host/bin/protoc \
    -DENABLE_SYSTEM_TBB=ON \
    -DOPENVINO_EXTRA_MODULES=/openvino_contrib/modules \
    -DIE_EXTRA_MODULES=/openvino_contrib/modules \
    -DBUILD_java_api=OFF \
    -DBUILD_mo_pytorch=OFF \
    -DBUILD_nvidia_plugin=OFF \
    -DBUILD_optimum=OFF \
    -DBUILD_ovms_ai_extension=OFF \
    -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF \
    -DENABLE_GAPI_PREPROCESSING=OFF \
    /openvino
ninja install
popd
}

#=========================================================

build_ffmpeg() {
D=/workspace/FFmpeg
[ -d ${D} ] || git clone ${GITOPT} --branch=${VFFMPEG} https://github.com/FFmpeg/FFmpeg ${D}
pushd ${D}
./configure \
    --cc=aarch64-linux-gnu-gcc \
    --cxx=aarch64-linux-gnu-g++ \
    --arch=aarch64 \
    --target-os=linux \
    --disable-x86asm \
    --enable-shared \
    --disable-static \
    --enable-cross-compile \
    --enable-pic \
    --prefix=/workspace/install \
    --cross-prefix=aarch64-linux-gnu- \
    --pkg-config=pkg-config
make -j${NCPU} install
popd
}

#=========================================================

build_opencv() {
D=/workspace/build-opencv
mkdir -p ${D}
pushd ${D} && rm -rf *
PKG_CONFIG_PATH=/workspace/install/lib/pkgconfig \
PKG_CONFIG_LIBDIR=/workspace/install/lib \
OpenVINO_DIR=/workspace/install/runtime/cmake \
cmake -GNinja \
    ${CMAKEOPT[@]} \
    -DCMAKE_TOOLCHAIN_FILE=/opencv/platforms/linux/aarch64-gnu.toolchain.cmake \
    -DOPENCV_EXTRA_EXE_LINKER_FLAGS="-Wl,--allow-shlib-undefined" \
    -DOPENCV_EXTRA_SHARED_LINKER_FLAGS="-Wl,--allow-shlib-undefined" \
    -DWITH_FFMPEG=ON \
    -DWITH_TBB=ON \
    -DWITH_OPENVINO=ON \
    -DBUILD_EXAMPLES=ON \
    -DINSTALL_TESTS=ON \
    -DBUILD_PROTOBUF=OFF \
    -DPROTOBUF_UPDATE_FILES=ON \
    -DProtobuf_PROTOC_EXECUTABLE=/workspace/host/bin/protoc \
    /opencv
ninja install
popd
}

build_opencv2() {
D=/workspace/build-opencv
mkdir -p ${D}
pushd ${D} && rm -rf *
PKG_CONFIG_LIBDIR=/workspace/install/lib/pkgconfig \
PKG_CONFIG_PATH=/workspace/install/lib/pkgconfig:/usr/lib/aarch64-linux-gnu/pkgconfig/:/usr/share/pkgconfig \
OpenVINO_DIR=/workspace/install/runtime/cmake \
cmake -GNinja \
    ${CMAKEOPT[@]} \
    -DCMAKE_TOOLCHAIN_FILE=/opencv/platforms/linux/aarch64-gnu.toolchain.cmake \
    -DOPENCV_EXTRA_EXE_LINKER_FLAGS="-Wl,--allow-shlib-undefined" \
    -DOPENCV_EXTRA_SHARED_LINKER_FLAGS="-Wl,--allow-shlib-undefined" \
    -DWITH_FFMPEG=ON \
    -DBUILD_EXAMPLES=ON \
    -DINSTALL_TESTS=ON \
    -DBUILD_PROTOBUF=OFF \
    -DPROTOBUF_UPDATE_FILES=ON \
    -DProtobuf_INCLUDE_DIR=/workspace/install/include \
    -DProtobuf_LIBRARY=/workspace/install/lib/libprotobuf.a \
    -DProtobuf_PROTOC_EXECUTABLE=/workspace/host/bin/protoc \
    -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
    -DWITH_FFMPEG=ON \
    -DWITH_GSTREAMER=ON \
    -DWITH_GTK=ON \
    -DCMAKE_FIND_ROOT_PATH="$(dirname $(find /usr -name Eigen3Config.cmake 2>/dev/null));/workspace/install/runtime/cmake" \
    -DPKG_CONFIG_EXECUTABLE=$(which aarch64-linux-gnu-pkg-config) \
    /opencv
    # -DWITH_EIGEN=ON \
    # -DWITH_TBB=ON \
    # -DWITH_OPENVINO=ON \
ninja install
popd
}

build_opencv_python() {
D=/workspace/build-opencv
mkdir -p ${D}
pushd ${D} && rm -rf *
cmake -GNinja \
    ${CMAKEOPT[@]} \
    -DCMAKE_TOOLCHAIN_FILE=/opencv/platforms/linux/aarch64-gnu.toolchain.cmake \
    -DINSTALL_TESTS=ON \
    -DCMAKE_INSTALL_PREFIX=/workspace/install \
    -DPYTHON3_INCLUDE_PATH=/usr/include/python3.11/ \
    -DPYTHON3_NUMPY_INCLUDE_DIRS=/usr/include/python3.11/numpy \
    /opencv
ninja install
popd
}

build_opencv_only() {
D=/workspace/build-opencv
mkdir -p ${D}
pushd ${D} && rm -rf *
cmake -GNinja \
    ${CMAKEOPT[@]} \
    -DCMAKE_TOOLCHAIN_FILE=/opencv/platforms/linux/aarch64-gnu.toolchain.cmake \
    -DBUILD_EXAMPLES=ON \
    -DINSTALL_TESTS=ON \
    -DCMAKE_INSTALL_PREFIX=/workspace/install \
    /opencv
ninja install

    # -DCMAKE_CXX_FLAGS=-march=armv8-a+nosimd -DENABLE_NEON=OFF \
    # -DWITH_OPENCL=OFF \
    # -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
    # -DCMAKE_CXX_FLAGS=-march=armv8-a+nosimd -DENABLE_NEON=OFF \
    # -DENABLE_NEON=OFF \
    # -DCV_DISABLE_OPTIMIZATION=ON \
    # -DENABLE_NEON=OFF \
    # -DCPU_BASELINE= \
    # -DCMAKE_CXX_FLAGS=-march=armv8-a \

popd
}


#=========================================================

test_opencv() {
name=$1
shift
mkdir -p /workspace/logs
pushd /workspace
OPENCV_TEST_DATA_PATH=/opencv_extra/testdata \
LD_LIBRARY_PATH=/workspace/install/lib:/workspace/install/runtime/lib/aarch64 \
qemu-aarch64 -L /usr/aarch64-linux-gnu/ \
    /workspace/install/bin/${name} --gtest_output=xml:/workspace/logs/${name}.log $*
popd
}

#=========================================================

# build_protobuf
# build_tbb
# build_openvino
# build_opencv2
# build_ffmpeg
# build_opencv
# build_opencv_only
build_opencv_python
# test_opencv opencv_test_core || true
# test_opencv opencv_test_dnn || true
# test_opencv opencv_test_gapi || true
# test_opencv opencv_version -v --threads --hw || true
