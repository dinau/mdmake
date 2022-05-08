TARGET = mdmake
GITHUB_REPO = d:/.cache/mdmake

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

all:$(TARGET)$(EXE)
	./$<

SRCS += src/mdmake.nim
SRCS += src/hashlib.nim
SRCS += src/md2htmlg.nim
SRCS += src/template_mdmake.nim

$(TARGET)$(EXE): $(SRCS) config.nims Makefile
	nim c  -o:$@ src/$(TARGET)
	#nimble build

.PHONEY:clean rel

TC = gcc
NIMCACHE = .nimcache
clean:
	rm -fr $(NIMCACHE)_$(TC)
	rm $(TARGET)$(EXE)

rel:
	cp src/*.nim    $(GITHUB_REPO)/src/
	cp config.nims 	$(GITHUB_REPO)/
	cp Makefile     $(GITHUB_REPO)/
	cp LICENSE      $(GITHUB_REPO)/
	cp README.md    $(GITHUB_REPO)/
	cp .gitignore   $(GITHUB_REPO)/
	cp setenv.bat   $(GITHUB_REPO)/
