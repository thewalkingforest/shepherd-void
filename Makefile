PREFIX ?= /usr/local

all:
	$(CC) $(CFLAGS) seedrng.c -o seedrng $(LDFLAGS)


install:
	install -m644 rc.conf ${DESTDIR}/etc
	install -m755 rc.local ${DESTDIR}/etc
	install -m755 rc.shutdown ${DESTDIR}/etc
	install -m755 seedrng ${DESTDIR}/${PREFIX}/sbin/seedrng
	install -m644 shepherd.scm ${DESTDIR}/${PREFIX}/etc
	install -d ${DESTDIR}/${PREFIX}/etc/shepherd.d
	install -m644 agetty-tty1.scm ${DESTDIR}/${PREFIX}/etc/shepherd.d
	install -m644 agetty-tty2.scm ${DESTDIR}/${PREFIX}/etc/shepherd.d
	install -m644 agetty-tty3.scm ${DESTDIR}/${PREFIX}/etc/shepherd.d
	install -m644 agetty-tty4.scm ${DESTDIR}/${PREFIX}/etc/shepherd.d
	install -m644 agetty-tty5.scm ${DESTDIR}/${PREFIX}/etc/shepherd.d
	install -m644 agetty-tty5.scm ${DESTDIR}/${PREFIX}/etc/shepherd.d
	install -m644 shutdown-tasks.scm ${DESTDIR}/${PREFIX}/etc/shepherd.d

.PHONY: all install
