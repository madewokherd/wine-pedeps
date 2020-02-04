
.SUFFIXES: #disable all builtin rules

# configuration
SRCDIR:=$(dir $(MAKEFILE_LIST))
BUILDDIR=$(SRCDIR)/build-$(ARCH)
IMAGEDIR=$(SRCDIR)/image-$(ARCH)
LIBDIR=$(SRCDIR)/lib-$(ARCH)
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

CMAKE_SYSTEM_PROCESSOR_x86=x86
CMAKE_SYSTEM_PROCESSOR_x86_64=x86_64
CMAKE_SYSTEM_PROCESSOR_arm=arm
CMAKE_SYSTEM_PROCESSOR_arm64=aarch64
CMAKE_SYSTEM_PROCESSOR=$(CMAKE_SYSTEM_PROCESSOR_$(ARCH))

CMAKE_COMMON_ARGS=-DCMAKE_SYSTEM_NAME=Windows -DCMAKE_SYSTEM_PROCESSOR=$(CMAKE_SYSTEM_PROCESSOR) -DCMAKE_C_COMPILER=$(MINGW)-gcc -DCMAKE_CXX_COMPILER=$(MINGW)-g++

all:
.PHONY: all

%-x86:
	+$(MAKE) $* ARCH=x86

%-x86_64:
	+$(MAKE) $* ARCH=x86_64

%-arm:
	+$(MAKE) $* ARCH=arm

%-arm64:
	+$(MAKE) $* ARCH=arm64

include llvm.make

all-arches: $(MINGW)-gcc
	+$(MAKE) all-x86 all-x86_64 all-arm all-arm64

include sdl2.make

include faudio.make

