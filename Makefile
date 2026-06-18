DESTDIR=
PREFIX ?= /usr/local

all:
	$(CC) $(CFLAGS) seedrng.c -o seedrng $(LDFLAGS)

install:
	install -d ${DESTDIR}/etc
	install -m644 rc.conf      ${DESTDIR}/etc
	install -m755 rc.local     ${DESTDIR}/etc
	install -m755 rc.shutdown  ${DESTDIR}/etc
	install -m644 shepherd.scm ${DESTDIR}/etc
	install -d ${DESTDIR}/${PREFIX}/bin
	install -m755 seedrng           ${DESTDIR}/${PREFIX}/bin
	install -m755 shepherd-init.sh  ${DESTDIR}/${PREFIX}/bin
	install -m755 service-autoloader ${DESTDIR}/${PREFIX}/bin

clean:
	$(RM) seedrng

.PHONY: all install clean
