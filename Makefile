PREFIX ?= /usr/local

all:
	$(CC) $(CFLAGS) seedrng.c -o seedrng $(LDFLAGS)


install:
	install -m644 shepherd.scm ${DESTDIR}/${PREFIX}/etc
	install -m644 rc.conf ${DESTDIR}/etc
	install -m755 rc.local ${DESTDIR}/etc
	install -m755 rc.shutdown ${DESTDIR}/etc

.PHONY: all install
