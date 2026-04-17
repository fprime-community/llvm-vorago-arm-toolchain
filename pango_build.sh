#!/bin/bash
set -e -u

dnf install -y \
    cairo-devel \
    fribidi-devel \
    gobject-introspection-devel \
    libffi-devel \
    libmount-devel

curl -L -O https://download.gnome.org/sources/glib/2.60/glib-2.60.7.tar.xz
tar -xf glib-2.60.7.tar.xz glib-2.60.7/

curl -L -O https://github.com/harfbuzz/harfbuzz/releases/download/2.6.8/harfbuzz-2.6.8.tar.xz
tar -xf harfbuzz-2.6.8.tar.xz harfbuzz-2.6.8/

curl -L -O https://download.gnome.org/sources/pango/1.44/pango-1.44.7.tar.xz
tar -xf pango-1.44.7.tar.xz pango-1.44.7/

export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/
export LD_LIBRARY_PATH=/usr/local/lib64/

mkdir staging
STAGING="$PWD/staging"

cd glib-2.60.7
meson setup builddir --prefix=/usr/local --wrap-mode=nofallback
ninja -C builddir
DESTDIR="$STAGING" ninja -C builddir install
cd ..

cd harfbuzz-2.6.8
meson setup builddir --prefix=/usr/local --wrap-mode=nofallback
ninja -C builddir
DESTDIR="$STAGING" ninja -C builddir install
cd ..

cd pango-1.44.7
meson setup builddir --prefix=/usr/local --wrap-mode=nofallback
ninja -C builddir
DESTDIR="$STAGING" ninja -C builddir install
cd ..

cd staging
tar -cJf "../Pango-Linux-$(uname -m).tar.xz" .
