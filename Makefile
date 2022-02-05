ifeq ($(OS),Windows_NT)
	EXE = .exe
endif
TARGET = mdmake

all: $(TARGET)$(EXE) genmd

genmd:
	./mdmake


#TC = tcc
TC = gcc
#TC = clang

NIMCACHE = .nimcache

OPT += -d:ssl
OPT += --cc:$(TC)
OPT += -d:danger --passL:-s --opt:size
OPT += --nimcache:$(NIMCACHE)_$(TC)

ifneq ($(TC),tcc)
OPT += --passC:"-ffunction-sections"
OPT += --passC:"-fdata-sections"
OPT += --passC:"-Wl,--gc-sections"
ifneq ($(TC),clang)
OPT += --passC:"-flto"
OPT += --passL:"-flto"
endif
endif

LIB_SRCS += src/hashlib.nim
LIB_SRCS += src/md2htmlg.nim
LIB_SRCS += src/template_mdmake.nim

$(TARGET)$(EXE):  src/$(TARGET).nim Makefile $(LIB_SRCS)
	nim c $(OPT) -o:$@ $<

.PHONEY:clean

clean:
	rm -fr $(NIMCACHE)_$(TC)
	rm *.exe

