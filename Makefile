src=$(wildcard ./*.c)
obj=$(patsubst ./%.c, ./%.o, $(src))
includedir = /usr/include/nservo
libdir = /usr/lib
execdir = /usr/bin
console_tool_src=$(wildcard ./tool/console_tool.c)
console_tool_obj=$(patsubst ./%.c, ./%.o, $(console_tool_src))

nservo_run_src=$(wildcard ./tool/nservo_run.c)
nservo_run_obj=$(patsubst ./%.c, ./%.o, $(nservo_run_src))

nservo_client_src=$(wildcard ./tool/nservo_client.c)
nservo_client_obj=$(patsubst ./%.c, ./%.o, $(nservo_client_src))

ifdef $(XENO_CONFIG)
CFLAGS := $(shell DESTDIR=$(XENO_DESTDIR)   $(XENO_CONFIG) --skin=posix --cflags)
LDFLAGS := $(shell DESTDIR=${XENO_DESTDIR} $(XENO_CONFIG) --skin=posix --ldflags)
endif

CFLAGS +=  $(shell $(XML2_CONFIG) --cflags)
LDFLAGS += $(shell $(XML2_CONFIG) --libs)

CFLAGS += -I./include -Ddebug_level=debug_level_info
LDFLAGS += -lpthread

lib = libnservo.a

all:lib console_tool nservo_run nservo_client

lib: $(obj)
	$(AR) -cr $(lib) $^
console_tool: $(console_tool_obj) lib
	$(CC) $< -o nser_console_tool -L. -lnservo -lethercat -lpthread $(LDFLAGS)  
nservo_run:  $(nservo_run_obj) lib
	$(CC) $< -o nservo_run -lnservo -L. -lethercat -lpthread $(LDFLAGS) 
nservo_client:  $(nservo_client_obj) lib
	$(CC) $< -o nservo_client $(LDFLAGS)  

install-libs:
	-@if [ ! -d $(DESTDIR)$(includedir) ]; then mkdir -p $(DESTDIR)$(includedir); fi
	cp include/* $(DESTDIR)$(includedir)
	cp libnservo.a $(DESTDIR)$(libdir)

install:
	cp nservo_run nservo_client nser_console_tool  $(DESTDIR)/$(execdir)
	- mkdir $(DESTDIR)/root/nservo_example
	cp ./example/hss248_ec_config_pp.xml  $(DESTDIR)/root/nservo_example
	cp ./example/hss248_ec_config_pv.xml  $(DESTDIR)/root/nservo_example

clean:
	rm *.o *.a
%.o:%.c
	$(CC)	-c $(CFLAGS)  -Wall -g   $< -o $@
#-Wfatal-errors -Werror $(CC)  -shared $(LDFLAGS) -o libnservo.so $< $(CC)  -fpic  -shared $(LDFLAGS) -o libnservo.so $<
