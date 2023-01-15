TARGET = mdmake
GITHUB_REPO = d:/.cache/mdmake

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

all:$(TARGET)$(EXE)
	@strings $(TARGET)$(EXE) | rg -i \.dll
	./$<

SRCS += src/mdmake.nim
SRCS += src/hashlib.nim
SRCS += src/md2htmlg.nim
SRCS += src/template_mdmake.nim

$(TARGET)$(EXE): $(SRCS) config.nims Makefile
	@#nim c  -o:$@ src/$(TARGET)
	nimble build

.PHONEY:clean rel

NIMCACHE = .nimcache

clean:
	-rm $(TARGET)$(EXE)
	-rm README.html
	-rm test_dir1/*.html
	-rm test_dir2/*.html
	-rm -fr .nimcache_*

rel:
	-rm -f  $(GITHUB_REPO)/config.nims
	-rm -f	$(GITHUB_REPO)/LICENSE
	-rm -f	$(GITHUB_REPO)/Makefile
	-rm -f	$(GITHUB_REPO)/README.md
	-rm -f  $(GITHUB_REPO)/src/*
	-cp src/*.nim    $(GITHUB_REPO)/src/
	-cp config.nims  $(GITHUB_REPO)/
	-cp Makefile     $(GITHUB_REPO)/
	-cp LICENSE      $(GITHUB_REPO)/
	-cp README.md    $(GITHUB_REPO)/
	-cp .gitignore   $(GITHUB_REPO)/
	-cp setenv.bat   $(GITHUB_REPO)/
	-cp *.nimble     $(GITHUB_REPO)/

dlls: all
	@strings $(TARGET)$(EXE) | rg -i \.dll
