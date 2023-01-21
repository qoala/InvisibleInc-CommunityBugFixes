#
# To get started, copy makeconfig.example.mk as makeconfig.mk and fill in the appropriate paths.
#
# build (default): Build all the zips and kwads. "out/" is suitable for uploading to Steam.
# install: Copy mod files into a local installation of Invisible Inc
#

include makeconfig.mk

.PHONY: build install clean distclean
.SECONDEXPANSION:

ensuredir = @mkdir -p $(@D)

files := modinfo.txt scripts.zip gui.kwad
outfiles := $(addprefix out/, $(files))
installfiles := $(addprefix $(INSTALL_PATH)/, $(files))

ifneq ($(INSTALL_PATH2),)
	installfiles += $(addprefix $(INSTALL_PATH2)/, $(files))
endif

build: $(outfiles)
install: build $(installfiles)

$(installfiles): %: out/$$(@F)
	$(ensuredir)
	cp $< $@

clean:
	-rm tactical-lamp-mod/build/*
	-rm out/*

distclean:
	-rm -f $(INSTALL_PATH)/*.kwad $(INSTALL_PATH)/*.zip
ifneq ($(INSTALL_PATH2),)
	-rm -f $(INSTALL_PATH2)/*.kwad $(INSTALL_PATH2)/*.zip
endif

out/modinfo.txt: modinfo.txt
	$(ensuredir)
	cp modinfo.txt out/modinfo.txt

#
# kwads and contained files
#

# anims := $(patsubst %.anim.d,%.anim,$(shell find anims -type d -name "*.anim.d"))
#
# $(anims): %.anim: $(wildcard %.anim.d/*.xml $.anim.d/*.png)
# 	cd $*.anim.d && zip ../$(notdir $@) *.xml *.png

gui_files := $(wildcard gui/**/*.png)

out/gui.kwad: $(gui_files)
	$(ensuredir)
	$(KWAD_BUILDER) -i build.lua -o out

#
# scripts
#

out/scripts.zip: $(shell find scripts -type f -name "*.lua")
	$(ensuredir)
	cd scripts && zip -r ../$@ . -i '*.lua'
