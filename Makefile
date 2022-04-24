TARGET = mdmake
GITHUB_REPO = d:/.cache/mdmake

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

all:
	nimble build
	./$(TARGET)$(EXE)

.PHONEY:clean rel

clean:
	rm -fr $(NIMCACHE)_$(TC)
	rm *.exe

rel:
	cp src/*.nim    $(GITHUB_REPO)/src/
	cp config.nims 	$(GITHUB_REPO)/
	cp Makefile 		$(GITHUB_REPO)/
	cp LICENSE      $(GITHUB_REPO)/
	cp README.md    $(GITHUB_REPO)/
	cp .gitignore   $(GITHUB_REPO)/
