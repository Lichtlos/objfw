include extra.mk

SUBDIRS = src utils ${TESTS}
DISTCLEAN = aclocal.m4		\
	    autom4te.cache	\
	    buildsys.mk		\
	    config.h		\
	    config.log		\
	    config.status	\
	    extra.mk		\
	    objfw-config

include buildsys.mk

tarball:
	V=$$(fgrep VERSION= objfw-config.in | sed 's/VERSION="\(.*\)"/\1/'); \
	V2=$$(fgrep AC_INIT configure.ac | \
	      sed 's/AC_INIT([^,]*,\([^,]*\),.*/\1/' | sed 's/ //'); \
	V3=$$(fgrep -A1 CFBundleVersion Info.plist | tail -1 | \
	      sed 's/.*>\(.*\)<.*/\1/'); \
	V4=$$(fgrep -A1 CFBundleShortVersion Info.plist | tail -1 | \
	      sed 's/.*>\(.*\)<.*/\1/'); \
	if test x"$$V2" != x"$$V" \
	    -o x"$$V3" != x"$$V" \
	    -o x"$$V4" != x"$$V4"; then \
		echo "Not all files have the same version number!"; \
		exit 1; \
	fi; \
	echo "Generating tarball for version $$V..."; \
	rm -f objfw-$$V.tar.gz; \
	rm -fr objfw-$$V; \
	hg archive objfw-$$V; \
	cp configure config.h.in objfw-$$V; \
	cd objfw-$$V && rm -f .hg_archival.txt .hgignore .hgtags && cd ..; \
	tar cf objfw-$$V.tar objfw-$$V; \
	gzip -9 objfw-$$V.tar; \
	rm -fr objfw-$$V
