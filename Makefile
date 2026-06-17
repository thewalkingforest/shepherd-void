DESTDIR ?=
PREFIX ?= /usr/local

all:
	$(CC) $(CFLAGS) seedrng.c -o seedrng $(LDFLAGS)

install:
	install -m644 -D -t ${DESTDIR}/etc rc.conf
	install -m755 -D -t ${DESTDIR}/etc rc.local
	install -m755 -D -t ${DESTDIR}/etc rc.shutdown
	install -m755 -D -t ${DESTDIR}/${PREFIX}/sbin/seedrng seedrng
	install -m644 -D -t ${DESTDIR}/etc shepherd.scm
	install -m644 -D -t ${DESTDIR}/${PREFIX}/sbin shepherd-init.sh
	install -m755 -D -t ${DESTDIR}/${PREFIX}/bin service-autoloader

clean:
	$(RM) seedrng

.PHONY: all install clean
