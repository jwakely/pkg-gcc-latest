BASE_VER := 14.0.1

MAJOR := $(basename $(basename $(BASE_VER)))
DEB := gcc-latest_$(BASE_VER)-$(DATE)git$(GITREV).deb
SHELL=bash

guess-version:
	@ls gcc-latest_$(BASE_VER)-20??????git????????????.deb \
		| sed -n '$$s/^gcc-latest_$(BASE_VER)-\(.*\)git\(.*\).deb$$/DATE=\1 GITREV=\2/p'

index.html: index.html.tmp
	if diff -q $@ $< ; then rm $< ; else mv $< $@ ; fi

index.html.tmp: index.html.m4 index.md Makefile $(DEB)
	[[ "$$DATE" =~ 20[0-9]{6} ]]
	[[ "$$GITREV" =~ [a-z0-9]{12} ]]
	m4 -DINPUT=index.md \
		-DMAJOR=$(MAJOR) -DDATE=$(DATE) -DGITREV=$(GITREV) \
		-DDEB=$(DEB) \
		index.html.m4 > $@

gcc-latest_$(BASE_VER)-git.deb:
	@echo "Variables DATE and GITREV are not set" >&2
	@echo "Use 'make guess-version' to guess them from the latest .deb" >&2
	@false

.PHONY: guess-version gcc-latest_-git.deb
.INTERMEDIATE: index.html.tmp

-include upload.mk
