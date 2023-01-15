TARGET = mdmake
GITHUB_REPO = ../00rel/mdmake

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

all:$(TARGET)$(EXE)
	@-strings $(TARGET)$(EXE) | rg -i \.dll
	./$<

SRCS += src/mdmake.nim
SRCS += src/hashlib.nim
SRCS += src/md2htmlg.nim
SRCS += src/template_mdmake.nim

$(TARGET)$(EXE): $(SRCS) config.nims version.nims Makefile
	@# version check
	@echo [mdmake.nimlbe]
	-@rg -ie "version\s+=.+" mdmake.nimble
	@echo [version.nims]
	-@rg -ie "\d\.\d\.\d" version.nims
	@#nim c  -o:$@ src/$(TARGET)
	nimble build

.PHONEY:clean rel

NIMCACHE = .nimcache

clean:
	-rm $(TARGET)$(EXE)
	-rm README.html
	-rm test_dir1/*.html
	-rm test_dir2/*.html
	-rm -fr .nimcache*

rel:
	-rm -f  $(GITHUB_REPO)/config.nims
	-rm -f	$(GITHUB_REPO)/LICENSE
	-rm -f	$(GITHUB_REPO)/Makefile
	-rm -f	$(GITHUB_REPO)/README.md
	-rm -f  $(GITHUB_REPO)/src/*
	-cp -u src/*.nim    $(GITHUB_REPO)/src/
	-cp -u *.nims       $(GITHUB_REPO)/
	-cp -u Makefile     $(GITHUB_REPO)/
	-cp -u LICENSE      $(GITHUB_REPO)/
	-cp -u README.md    $(GITHUB_REPO)/
	-cp -u .gitignore   $(GITHUB_REPO)/
	-cp -u setenv.bat   $(GITHUB_REPO)/
	-cp -u *.nimble     $(GITHUB_REPO)/
	-cp -u mdmake.dir   $(GITHUB_REPO)/

dlls: all
	@-strings $(TARGET)$(EXE) | rg -i \.dll
