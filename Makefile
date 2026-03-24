PREFIX ?= /usr/local

all:
	$(CC) $(CFLAGS) seedrng.c -o seedrng $(LDFLAGS)


install:
	install -d ${DESTDIR}/${PREFIX}/etc
	install -m644 rc.conf ${DESTDIR}/etc
	install -m755 rc.local ${DESTDIR}/etc
	install -m755 rc.shutdown ${DESTDIR}/etc
	install -m755 seedrng ${DESTDIR}/${PREFIX}/sbin/seedrng
	install -m644 shepherd.scm ${DESTDIR}/etc
	install -m644 shepherd-init.sh ${DESTDIR}/${PREFIX}/sbin
	install -d ${DESTDIR}/etc/shepherd.d
	install -m644 services/agetty-tty1.scm ${DESTDIR}/etc/shepherd.d
	install -m644 services/agetty-tty2.scm ${DESTDIR}/etc/shepherd.d
	install -m644 services/agetty-tty3.scm ${DESTDIR}/etc/shepherd.d
	install -m644 services/agetty-tty4.scm ${DESTDIR}/etc/shepherd.d
	install -m644 services/agetty-tty5.scm ${DESTDIR}/etc/shepherd.d
	install -m644 services/agetty-tty5.scm ${DESTDIR}/etc/shepherd.d
	install -m644 services/shutdown-tasks.scm ${DESTDIR}/etc/shepherd.d

.PHONY: all install
