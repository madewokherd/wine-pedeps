
.SUFFIXES: #disable all builtin rules

# configuration
SRCDIR:=$(dir $(MAKEFILE_LIST))
BUILDDIR=$(SRCDIR)/build-$(ARCH)
IMAGEDIR=$(SRCDIR)/image-$(ARCH)
LIBDIR=$(SRCDIR)/libs-$(ARCH)
INCLUDEDIR=$(SRCDIR)/include-$(ARCH)

ifeq ($(shell test -d $(SRCDIR)/output && echo y),y)
OUTDIR=$(SRCDIR)/output
else
OUTDIR=$(SRCDIR)
endif

ARCH=x86

BUILD_TRIPLE=x86_64-pc-linux-gnu

MINGW_TRIPLE_x86=i686-w64-mingw32
MINGW_TRIPLE_x86_64=x86_64-w64-mingw32
MINGW_TRIPLE_arm=armv7-w64-mingw32
MINGW_TRIPLE_arm64=aarch64-w64-mingw32
MINGW_TRIPLE=$(MINGW_TRIPLE_$(ARCH))

ARCH_CFLAGS_arm=-mfloat-abi=soft
ARCH_CFLAGS=$(ARCH_CFLAGS_$(ARCH))

ARCH_CXXFLAGS_arm=-mfloat-abi=soft
ARCH_CXXFLAGS=$(ARCH_CXXFLAGS_$(ARCH))

WINE=wine

FETCH_LLVM_MINGW_VERSION=20191230
FETCH_LLVM_MINGW_DIRECTORY=llvm-mingw-$(FETCH_LLVM_MINGW_VERSION)-ubuntu-16.04

FETCH_LLVM_MINGW_ARCHIVE=$(FETCH_LLVM_MINGW_DIRECTORY).tar.xz
FETCH_LLVM_MINGW_URL=https://github.com/mstorsjo/llvm-mingw/releases/download/$(FETCH_LLVM_MINGW_VERSION)/$(FETCH_LLVM_MINGW_ARCHIVE)

FETCH_LLVM_MINGW=$(SRCDIR_ABS)/$(FETCH_LLVM_MINGW_DIRECTORY)/bin/$(MINGW_TRIPLE_$(ARCH))

MINGW=$(FETCH_LLVM_MINGW)

-include user-config.make

MSI_VERSION=4.9.99

# variables
SRCDIR_ABS:=$(shell cd $(SRCDIR); pwd)
BUILDDIR_ABS=$(shell cd $(BUILDDIR); pwd)
IMAGEDIR_ABS=$(shell cd $(IMAGEDIR); pwd)
OUTDIR_ABS=$(shell cd $(OUTDIR); pwd)
LIBDIR_ABS=$(shell cd $(LIBDIR); pwd)
INCLUDEDIR_ABS=$(shell cd $(INCLUDEDIR); pwd)

all:
.PHONY: all

# automatically fetching and extracting llvm-mingw

$(SRCDIR)/$(FETCH_LLVM_MINGW_ARCHIVE):
	wget '$(FETCH_LLVM_MINGW_URL)' -O $@

$(FETCH_LLVM_MINGW)-gcc: $(SRCDIR)/$(FETCH_LLVM_MINGW_ARCHIVE)
	cd $(SRCDIR); tar xvf $(FETCH_LLVM_MINGW_ARCHIVE)

fetch-llvm: $(FETCH_LLVM_MINGW)-gcc
.PHONY: fetch-llvm

# SDL2

SDL2_SRCDIR=$(SRCDIR_ABS)/SDL2

# note: we explicitly disable vsscanf as msvcrt doesn't support it and mingw-w64's wrapper is buggy
$(BUILDDIR)/SDL2/Makefile: $(SDL2_SRCDIR)/configure
	mkdir -p $(@D)
	cd $(@D); CC="$(MINGW)-gcc -static-libgcc $(ARCH_CFLAGS)" CXX="$(MINGW)-g++ -static-libgcc -static-libstdc++ $(ARCH_CXXFLAGS)" $< --build=x86_64-pc-linux-gnu --target=$(MINGW_TRIPLE) --host=$(MINGW_TRIPLE) PKG_CONFIG=false ac_cv_func_vsscanf=no

$(BUILDDIR)/SDL2/.built: $(BUILDDIR)/SDL2/Makefile
	+WINEPREFIX=/dev/null $(MAKE) -C $(@D)
	touch "$@"
