BASE_VER := 10.0.0

MAJOR := $(basename $(basename $(BASE_VER)))
DEB := gcc-latest_$(BASE_VER)-$(DATE)svn$(SVNREV).deb
SHELL=bash

guess-version:
	@ls gcc-latest_$(BASE_VER)-20??????svn??????.deb \
		| sed -n '$$s/^gcc-latest_$(BASE_VER)-\(.*\)svn\(.*\).deb$$/DATE=\1 SVNREV=\2/p'

index.html: index.html.m4 index.md Makefile $(DEB)
	[[ "$$DATE" =~ 20[0-9]{6} ]]
	[[ "$$SVNREV" =~ [1-9][0-9]{5} ]]
	m4 -DINPUT=index.md \
		-DMAJOR=$(MAJOR) -DDATE=$(DATE) -DSVNREV=$(SVNREV) \
		-DDEB=$(DEB) \
		index.html.m4 > $@

.PHONY: guess-version

-include upload.mk
