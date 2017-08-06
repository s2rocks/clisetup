VERSION		:= 1.0.0

sysconfdir	?= /etc

PREFIX		?=

LIB_FILES	:= libalpine.sh
SBIN_FILES	:= clisetup\
		setup-spkcache\
		setup-spkrepos\
		setup-bootable\
		setup-disk\
		setup-dns\
		setup-hostname\
		setup-interfaces\
		setup-keymap\
		setup-ntp\
		setup-proxy\
		setup-sshd\
		setup-timezone\
		update-conf\
		update-kernel

BIN_FILES	:= uniso

SCRIPTS		:= $(LIB_FILES) $(SBIN_FILES)


GIT_REV		:= $(shell test -d .git && git describe || echo exported)
ifneq ($(GIT_REV), exported)
FULL_VERSION	:= $(patsubst $(PACKAGE)-%,%,$(GIT_REV))
FULL_VERSION	:= $(patsubst v%,%,$(FULL_VERSION))
else
FULL_VERSION	:= $(VERSION)
endif


DESC="S2 CLI Setup"
WWW="http://s2linux.me/"


SED		:= sed

SED_REPLACE	:= -e 's:@VERSION@:$(FULL_VERSION):g' \
			-e 's:@PREFIX@:$(PREFIX):g' \
			-e 's:@sysconfdir@:$(sysconfdir):g'

.SUFFIXES:	.sh.in .in
%.sh: %.sh.in
	${SED} ${SED_REPLACE} ${SED_EXTRA} $< > $@

%: %.in
	${SED} ${SED_REPLACE} ${SED_EXTRA} $< > $@

.PHONY:	all apk clean install uninstall
all:	$(SCRIPTS) $(BIN_FILES)

uniso:	uniso.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

apk:	$(APKF)

install: $(BIN_FILES) $(SBIN_FILES) $(LIB_FILES)
	install -m 755 -d $(DESTDIR)/$(PREFIX)/bin
	install -m 755 $(BIN_FILES) $(DESTDIR)$(PREFIX)/bin
	install -m 755 -d $(DESTDIR)/$(PREFIX)/sbin
	install -m 755 $(SBIN_FILES) $(DESTDIR)/$(PREFIX)/sbin
	install -m 755 -d $(DESTDIR)/$(PREFIX)/lib
	install -m 755 $(LIB_FILES) $(DESTDIR)/$(PREFIX)/lib
	install -m 755 -d $(DESTDIR)/$(sysconfdir)

uninstall:
	for i in $(SBIN_FILES); do \
		rm -f "$(DESTDIR)/$(PREFIX)/sbin/$$i";\
	done
	for i in $(LIB_FILES); do \
		rm -f "$(DESTDIR)/$(PREFIX)/lib/$$i";\
	done

clean:
	rm -rf $(SCRIPTS) $(BIN_FILES)
