## cutearm

To compile Qt for Raspberry, there are generally two ways:

1. compile on device
2. use cross-compilation

First solution might be slow: have you ever tried to compile Qt on Raspberry 1? It takes more than 24 hours and you're not really satisfied when compilation breaks 1 hour after you started it while you're in your bed dreaming to get those `.so` files.

Second solution works well but is not easy to setup and maintained.

Here is a third solution which takes advantage of docker ARM images in order to work directly on Raspbian like on your Raspberry but within a container.

## Overall steps

* Create a Raspbian docker image
* Build a container based on this image with Qt compilation deps
* SSH on this container and perform compilation steps of Qt

## Steps

* `./build-raspbian-docker-image`: create a raspbian docker image
* `./build-raspbian-docker-container`: create the container able to compile Qt
* `./start-raspbian-docker-container`: start the container with volumes mounted

User is `worker`, password too.

* `docker inspect` to get the container IP
* `ssh worker@ip`
* Then:

```bash
wget http://download.qt.io/official_releases/qt/5.12/5.12.0/single/qt-everywhere-src-5.12.0.tar.xz
wget http://download.qt.io/official_releases/qt/5.12/5.12.0/single/md5sums.txt
md5sum --check --ignore-missing md5sums.txt
tar xf qt-everywhere-src-5.12.0.tar.xz
mkdir build
cd build

PKG_CONFIG_LIBDIR=/usr/lib/arm-linux-gnueabihf/pkgconfig:/usr/share/pkgconfig \
../qt-everywhere-src-5.12.0/configure \
-v \
-opengl es2 -eglfs \
-no-gtk \
-opensource -confirm-license -release \
-reduce-exports \
-force-pkg-config \
-nomake examples -no-compile-examples \
-skip qtwayland \
-skip qtwebengine \
-skip qt3d \
-skip qtscript \
-no-feature-geoservices_mapboxgl \
-qt-pcre \
-no-pch \
-ssl \
-evdev \
-system-freetype \
-fontconfig \
-glib \
-prefix /usr/workspace/Qt5.12.0 \
-qpa eglfs \
-sctp \
QMAKE_CFLAGS="-march=armv6zk -mtune=arm1176jzf-s -mfpu=vfp" \
QMAKE_CXXFLAGS="-march=armv6zk -mtune=arm1176jzf-s -mfpu=vfp" \
QMAKE_LIBS_EGL="-lEGL -lGLESv2" QMAKE_LIBS_OPENVG="-lEGL -lOpenVG -lGLESv2" \
QMAKE_LIBDIR_OPENGL_ES2=/opt/vc/lib QMAKE_INCDIR_OPENGL_ES2="/opt/vc/include /opt/vc/include/interface/vcos/pthreads /opt/vc/include/interface/vmcs_host/linux" \
QMAKE_LIBDIR_EGL=/opt/vc/lib QMAKE_INCDIR_EGL="/opt/vc/include /opt/vc/include/interface/vcos/pthreads /opt/vc/include/interface/vmcs_host/linux" \
QMAKE_LIBDIR_OPENVG=/opt/vc/lib QMAKE_INCDIR_OPENVG="/opt/vc/include /opt/vc/include/interface/vcos/pthreads /opt/vc/include/interface/vmcs_host/linux" \
-DEGLFS_DEVICE_INTEGRATION=eglfs_brcm

make
make install
```

This takes around 10h to compile Qt on an average machine.

## Test

```bash
mkdir qt-sample-app-build
cd qt-sample-app-build
../Qt5.12.0/bin/qmake -recursive ../qt-sample-app/qt-sample-app.pro
make
./qt-sample-app
```
