SDL2_SRCDIR=$(SRCDIR_ABS)/SDL2

# disabling dinput.h needed because llvm-mingw misses dinput8 lib but configure doesn't check
# disabling hidapi because llvm-mingw arm64 misses a setupapi lib
SDL2_ARCHCONFIG_arm=ac_cv_header_dinput_h=no
SDL2_ARCHCONFIG_arm64=ac_cv_header_dinput_h=no --disable-hidapi
SDL2_ARCHCONFIG=$(SDL2_ARCHCONFIG_$(ARCH))

# we explicitly disable vsscanf as msvcrt doesn't support it and mingw-w64's wrapper is buggy
$(BUILDDIR)/SDL2/Makefile: $(SDL2_SRCDIR)/configure $(MINGW)-gcc $(SRCDIR)/sdl2.make
	mkdir -p $(@D)
	cd $(@D); CC="$(MINGW)-gcc -static-libgcc $(ARCH_CFLAGS)" CXX="$(MINGW)-g++ -static-libgcc -static-libstdc++ $(ARCH_CXXFLAGS)" $< --build=x86_64-pc-linux-gnu --target=$(MINGW_TRIPLE) --host=$(MINGW_TRIPLE) PKG_CONFIG=false ac_cv_func_vsscanf=no ac_cv_prog_WINDRES=$(MINGW)-windres $(SDL2_ARCHCONFIG)

$(BUILDDIR)/SDL2/.built: $(BUILDDIR)/SDL2/Makefile
	+WINEPREFIX=/dev/null $(MAKE) -C $(@D)
	touch "$@"
