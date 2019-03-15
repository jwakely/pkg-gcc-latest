index.html: index.html.m4 index.md Makefile
	m4 -DINPUT=index.md index.html.m4 > $@
