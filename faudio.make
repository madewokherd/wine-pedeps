FAUDIO_SRCDIR=$(SRCDIR_ABS)/FAudio

$(BUILDDIR)/FAudio/Makefile: $(FAUDIO_SRCDIR)/CMakeLists.txt $(MINGW)-gcc $(SRCDIR)/faudio.make sdl2
	mkdir -p $(@D)
	cd $(@D); cmake $(CMAKE_COMMON_ARGS) -DSDL2_INCLUDE_DIRS="$(INCLUDEDIR_ABS)" -DSDL2_LIBRARIES="$(SDL2_LIB)" $(FAUDIO_SRCDIR)

$(BUILDDIR)/FAudio/.built: $(BUILDDIR)/FAudio/Makefile
	+$(MAKE) -C $(@D)
	touch "$@"

$(IMAGEDIR)/FAudio.dll: $(BUILDDIR)/FAudio/.built
	mkdir -p $(@D)
	cp $(BUILDDIR)/FAudio/FAudio.dll $@

$(LIBDIR)/libFAudio.dll.a: $(BUILDDIR)/FAudio/.built
	mkdir -p $(@D)
	cp $(BUILDDIR)/FAudio/libFAudio.dll.a $@

$(INCLUDEDIR)/FAudio.h: $(BUILDDIR)/FAudio/.built
	mkdir -p $(@D)
	cp $(FAUDIO_SRCDIR)/include/*.h $(@D)

faudio: $(IMAGEDIR)/FAudio.dll $(LIBDIR)/libFAudio.dll.a $(INCLUDEDIR)/FAudio.h
.PHONY: faudio

all: faudio
