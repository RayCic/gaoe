#!/bin/bash
# Copyright 2016 Raimonds Cicans <ray@apollo.lv>
# Distributed under the terms of the GNU General Public License v2

#
# Script's purpose is to analyse elf binary files (executables and
# shared libraries) and return list of Gentoo packages those files
# depends on.
#
# Arguments: list of elf binary files
#
# Returns: unified list of Gentoo packages those files depends on
#
# Important! System packages (sys-libs/glibc and sys-devel/gcc)
# are omitted.
#

### DATA ###

# Associative array of generic shared libraries and packages they belongs

declare -A userlibs=(
	['libX11.so.6']='x11-libs/libX11'
	['libfreetype.so.6']='media-libs/freetype'
	['libSDL2_image-2.0.so.0']='media-libs/sdl2-image'
	['libSDL2-2.0.so.0']='media-libs/libsdl2'
	['libGL.so.1']='virtual/opengl'
	['libglib-2.0.so.0']='dev-libs/glib:2'
	['libSDL2_ttf-2.0.so.0']='media-libs/sdl2-ttf'
	['libcairo.so.2']='x11-libs/cairo'
	['libgtk-x11-2.0.so.0']='x11-libs/gtk+:2'
	['libgdk-x11-2.0.so.0']='x11-libs/gtk+:2'
	['libgobject-2.0.so.0']='dev-libs/glib:2'
	['libgdk_pixbuf-2.0.so.0']='x11-libs/gdk-pixbuf:2'
	['libgtk-3.so.0']='x11-libs/gtk+:3'
	['libSDL-1.2.so.0']='media-libs/libsdl'
	['libogg.so.0']='media-libs/libogg'
	['libopenal.so.1']='media-libs/openal'
	['libvorbisfile.so.3']='media-libs/libvorbis'
	['libvorbis.so.0']='media-libs/libvorbis'
	['libz.so.1']='sys-libs/zlib'
	['libGLU.so.1']='virtual/glu'
	['libtheoradec.so.1']='media-libs/libtheora'
	['libfontconfig.so.1']='media-libs/fontconfig'
	['libIL.so.1']='media-libs/devil'
	['libtheora.so.0']='media-libs/libtheora'
	['libXext.so.6']='x11-libs/libXext'
	['libXft.so.2']='x11-libs/libXft'
	['libXcursor.so.1']='x11-libs/libXcursor'
	['libpng12.so.0']='media-libs/libpng:1.2'
	['libSDL_mixer-1.2.so.0']='media-libs/sdl-mixer'
	['libtiff.so.3']='media-libs/tiff:3'
	['libjpeg.so.62']='virtual/jpeg:62'
	['libstdc++.so.5']='sys-libs/libstdc++-v3'
	['libatk-1.0.so.0']='dev-libs/atk'
	['libgio-2.0.so.0']='dev-libs/glib:2'
	['libgmodule-2.0.so.0']='dev-libs/glib:2'
	['libgthread-2.0.so.0']='dev-libs/glib:2'
	['libpangocairo-1.0.so.0']='x11-libs/pango'
	['libpangoft2-1.0.so.0']='x11-libs/pango'
	['libpango-1.0.so.0']='x11-libs/pango'
)

# Associative array of system shared libraries and packages they belongs

declare -A systemlibs=(
	['libc.so.6']='sys-libs/glibc'
	['libpthread.so.0']='sys-libs/glibc'
	['libgcc_s.so.1']='sys-devel/gcc'
	['libm.so.6']='sys-libs/glibc'
	['libstdc++.so.6']='sys-devel/gcc'
	['libdl.so.2']='sys-libs/glibc'
	['librt.so.1']='sys-libs/glibc'
	['ld-linux-x86-64.so.2']='sys-libs/glibc'
	['ld-linux.so.2']='sys-libs/glibc'
)

### CODE ###

if [ $# -eq 0 ] ; then
	echo "No arguments supplied"
	exit
fi

for file in "$@"; do
	libs=`readelf -d "$file" | awk -F'[][]' '/\(NEEDED\)/ {print $2}'`

	for l in  ${libs}; do
		if [ ${systemlibs["$l"]+_} ]; then
			:
		else
			if [ ${userlibs["$l"]+_} ]; then
				echo ${userlibs["$l"]}
			else
				echo "__UNKNOWN($l)"
			fi
		fi
	done
done | sort -V | uniq
