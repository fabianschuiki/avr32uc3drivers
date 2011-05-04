# Makefile for building AVR32 toolchain (bare metal, newlib based)
#
# By Martin Lund <mgl@doredevelopment.dk>

# Target
TARGET = avr32

# Directories
SOURCES_DIR := ${PWD}/sources
BUILD_DIR := ${PWD}/build
PATCHES_DIR := ${PWD}/patches
PREFIX := ${BUILD_DIR}/${TARGET}

# Source versions

VERSION_BINUTILS = 2.18
VERSION_GCC = 4.2.2
VERSION_GMP = 4.3.1
VERSION_MPFR = 2.4.1
VERSION_GDB = 6.7.1
VERSION_NEWLIB = 1.17.0
VERSION_AVR_LIBC = 1.6.1

# Tool flags
MKDIR_FLAGS = -p
RM_FLAGS = -rf
WGET_FLAGS = -nc
TAR_FLAGS_BZ2 = xjf
TAR_FLAGS_GZ = xzf
TAR_FLAGS_LZMA = xv --lzma -f
BUNZIP2_FLAGS = -kf

# Add toolchain to path
PATH := ${PREFIX}/bin:${PATH}

# Default target
all: download extract patches binutils gcc newlib avr32headers

dirs:
	mkdir ${MKDIR_FLAGS} ${SOURCES_DIR}
	mkdir ${MKDIR_FLAGS} ${BUILD_DIR}
	mkdir ${MKDIR_FLAGS} ${PATCHES_DIR}
	mkdir ${MKDIR_FLAGS} ${PREFIX}

download: dirs
	wget ${WGET_FLAGS} -P ${SOURCES_DIR} ftp://gcc.gnu.org/pub/binutils/releases/binutils-${VERSION_BINUTILS}.tar.bz2
	wget ${WGET_FLAGS} -P ${SOURCES_DIR} http://avr32linux.org/twiki/pub/Main/BinutilsPatches/binutils-${VERSION_BINUTILS}.tar.bz2
	wget ${WGET_FLAGS} -P ${SOURCES_DIR} ftp://gcc.gnu.org/pub/gcc/releases/gcc-${VERSION_GCC}/gcc-core-${VERSION_GCC}.tar.bz2
	wget ${WGET_FLAGS} -P ${SOURCES_DIR} ftp://gcc.gnu.org/pub/gcc/releases/gcc-${VERSION_GCC}/gcc-g++-${VERSION_GCC}.tar.bz2
	wget ${WGET_FLAGS} -P ${SOURCES_DIR} ftp://gcc.gnu.org/pub/gcc/releases/gcc-${VERSION_GCC}/gcc-testsuite-${VERSION_GCC}.tar.bz2
	wget ${WGET_FLAGS} -P ${SOURCES_DIR} ftp://sourceware.org/pub/gdb/releases/gdb-${VERSION_GDB}.tar.bz2
	wget ${WGET_FLAGS} -P ${SOURCES_DIR} ftp://sources.redhat.com/pub/newlib/newlib-${VERSION_NEWLIB}.tar.gz
	wget ${WGET_FLAGS} -P ${PATCHES_DIR} http://avr32linux.org/twiki/pub/Main/GccPatches/gcc-4.2.2.atmel.1.1.3.patch.bz2
	wget ${WGET_FLAGS} -P ${PATCHES_DIR} http://avr32linux.org/twiki/pub/Main/BinutilsPatches/binutils-2.18.atmel.1.0.1.patch.bz2
	wget ${WGET_FLAGS} -P ${PATCHES_DIR} http://dev.doredevelopment.dk/avr32-toolchain/patches/newlib-1.17.0.avr32.patch.tar.gz
	wget ${WGET_FLAGS} -P ${PATCHES_DIR} http://dev.doredevelopment.dk/avr32-toolchain/patches/gdb-6.7.1.atmel.1.0.3.patch.tar.gz
	wget ${WGET_FLAGS} -P ${SOURCES_DIR} http://dev.doredevelopment.dk/avr32-toolchain/sources/avr32headers.tar.gz

#	wget ${WGET_FLAGS} -P ${SOURCES_DIR} http://download.savannah.gnu.org/releases/avr-libc/avr-libc-${VERSION_AVR_LIBC}.tar.bz2
#	wget ${WGET_FLAGS} -P ${SOURCES_DIR} ftp://ftp.gmplib.org/pub/gmp-${VERSION_GMP}/gmp-${VERSION_GMP}.tar.lzma
#	wget ${WGET_FLAGS} -P ${SOURCES_DIR} http://www.mpfr.org/mpfr-current/mpfr-${VERSION_MPFR}.tar.lzma

extract:
	tar ${TAR_FLAGS_BZ2} ${SOURCES_DIR}/binutils-${VERSION_BINUTILS}.tar.bz2 -C ${BUILD_DIR}
	tar ${TAR_FLAGS_BZ2} ${SOURCES_DIR}/gcc-core-${VERSION_GCC}.tar.bz2 -C ${BUILD_DIR}
	tar ${TAR_FLAGS_BZ2} ${SOURCES_DIR}/gcc-g++-${VERSION_GCC}.tar.bz2 -C ${BUILD_DIR}
	tar ${TAR_FLAGS_BZ2} ${SOURCES_DIR}/gcc-testsuite-${VERSION_GCC}.tar.bz2 -C ${BUILD_DIR}
	tar ${TAR_FLAGS_BZ2} ${SOURCES_DIR}/gdb-${VERSION_GDB}.tar.bz2 -C ${BUILD_DIR}
	tar ${TAR_FLAGS_GZ} ${SOURCES_DIR}/newlib-${VERSION_NEWLIB}.tar.gz -C ${BUILD_DIR}
	bunzip2 ${BUNZIP2_FLAGS} ${PATCHES_DIR}/gcc-4.2.2.atmel.1.1.3.patch.bz2
	bunzip2 ${BUNZIP2_FLAGS} ${PATCHES_DIR}/binutils-2.18.atmel.1.0.1.patch.bz2
	tar ${TAR_FLAGS_GZ} ${PATCHES_DIR}/newlib-1.17.0.avr32.patch.tar.gz -C ${PATCHES_DIR}
	tar ${TAR_FLAGS_GZ} ${PATCHES_DIR}/gdb-6.7.1.atmel.1.0.3.patch.tar.gz -C ${PATCHES_DIR}
	tar ${TAR_FLAGS_GZ} ${SOURCES_DIR}/avr32headers.tar.gz -C ${BUILD_DIR}

#	tar ${TAR_FLAGS_BZ2} ${SOURCES_DIR}/avr-libc-${VERSION_AVR_LIBC}.tar.bz2 -C ${BUILD_DIR}
#	tar ${TAR_FLAGS_LZMA} ${SOURCES_DIR}/gmp-${VERSION_GMP}.tar.lzma -C ${BUILD_DIR}
#	mv ${BUILD_DIR}/gmp-${VERSION_GMP} ${BUILD_DIR}/gcc-${VERSION_GCC}/gmp
#	tar ${TAR_FLAGS_LZMA} ${SOURCES_DIR}/mpfr-${VERSION_MPFR}.tar.lzma -C ${BUILD_DIR}
#	mv ${BUILD_DIR}/mpfr-${VERSION_MPFR} ${BUILD_DIR}/gcc-${VERSION_GCC}/mpfr

patches: 
	cd ${BUILD_DIR}/binutils-${VERSION_BINUTILS}; \
	patch -p1 < ${PATCHES_DIR}/binutils-2.18.atmel.1.0.1.patch
	cd ${BUILD_DIR}/gcc-${VERSION_GCC}; \
	patch -p1 < ${PATCHES_DIR}/gcc-4.2.2.atmel.1.1.3.patch
	cd ${BUILD_DIR}/newlib-${VERSION_NEWLIB}; \
	patch -p2 < ${PATCHES_DIR}/newlib-1.17.0.avr32.patch
	cd ${BUILD_DIR}/gdb-${VERSION_GDB}; \
	patch -p1 < ${PATCHES_DIR}/gdb-6.7.1.atmel.1.0.3.patch

binutils:
	cd ${BUILD_DIR}/binutils-${VERSION_BINUTILS}; \
	./configure --target=${TARGET} --prefix=${PREFIX} \
	--disable-nls \
	--disable-shared \
	--disable-threads \
	--with-gcc \
	--with-gnu-as \
	--with-gnu-ld \
	--with-dwarf2 \
	--disable-werror; \
	make all-bfd TARGET-bfd=headers; \
	rm bfd/Makefile; \
	make configure-bfd; \
	make; \
	make install

# Note: --disable-werror is added to avoid compile break by warning (eg. ubuntu gcc is too restrictive)

# Bootstrap gcc (C only compiler)
gcc:
	cd ${BUILD_DIR}/gcc-${VERSION_GCC}; \
	./configure --target=${TARGET} --prefix=${PREFIX} \
	--enable-__cxa_atexit \
	--disable-shared \
	--disable-nls \
	--without-included-gettext \
	--with-newlib \
	--disable-libssb \
	--disable-libssp \
	--disable-libstdcxx-pch \
	--with-dwarf2 \
	--enable-version-specific-runtime-libs \
	--enable-languages=c \
	--enable-newlib-io-long-long \
	--enable-newlib-io-long-double \
	--enable-newlib-io-pos-args; \
	make; \
	make install

#	--enable-languages=c,c++ fails! (why?)

#	cd ${BUILD_DIR}/gcc-${VERSION_GCC}; \
#	./configure --target=${TARGET} --prefix=${PREFIX} \
#	--disable-nls --disable-shared --disable-threads \
#	--disable-libssp --disable-libgomp --with-newlib \
#	--enable-languages="c" --disable-libmudflap; \
#	make; \
#	make install

newlib:
	cd ${BUILD_DIR}/newlib-${VERSION_NEWLIB}; \
	./configure --target=${TARGET} --prefix=${PREFIX}; \
	make; \
	make install

avr32headers:
	mkdir ${MKDIR_FLAGS} ${BUILD_DIR}/avr32/avr32/include/avr32
	cp -r ${BUILD_DIR}/avr32headers/*.* ${BUILD_DIR}/avr32/avr32/include/avr32

gcc-final:
	cd ${BUILD_DIR}/gcc-${VERSION_GCC}; \
	./configure --target=${TARGET} --prefix=${PREFIX} \
	--disable-nls --disable-shared --disable-threads \
	--enable-languages="c,c++" --disable-libmudflap \
	--disable-libssp --disable-libgomp --with-newlib;\
	make; \
	make install

gdb:
	cd ${BUILD_DIR}/gdb-${VERSION_GDB}; \
	./configure --target=${TARGET} --prefix=${PREFIX} \
	--disable-nls --disable-werror; \
	make all-bfd TARGET-bfd=headers; 
#	make; \
#	make install

# Fails on missing target bfd support! (configure: error: *** unknown target vector bfd_elf32_avr32_vec)

distclean: clean
	rm ${RM_FLAGS} ${SOURCES_DIR}

clean:
	rm ${RM_FLAGS} ${BUILD_DIR}
	rm ${RM_FLAGS} ${PATCHES_DIR}

.PHONY: all dirs download clean distclean extract patches binutils newlib gcc gcc-final gdb avr32headers

