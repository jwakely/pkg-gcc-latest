BASE_VER=9.0.1

MAJOR=$(basename $(basename $(BASE_VER)))
SHELL=bash

index.html: index.html.m4 index.md Makefile
	[[ "$$DATE" =~ 20[0-9]{6} ]]
	[[ "$$SVNREV" =~ [1-9][0-9]{5} ]]
	m4 -DINPUT=index.md \
		-DMAJOR=$(MAJOR) -DDATE=$(DATE) -DSVNREV=$(SVNREV) \
		-DDEB=gcc-latest_$(BASE_VER)-$(DATE)svn$(SVNREV).deb \
		index.html.m4 > $@
