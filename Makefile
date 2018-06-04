COMP=fpc-3.0.4/bin/fpc
FLAGS=
EXEC=qwirkle

all: legal uix core
	$(COMP) main.pas

test: legal uix core
	$(COMP) test.pas

legal: legal/legal.pas
	$(COMP) legal/legal.pas

uix: uix/consoleUI/console.pas
	$(COMP) uix/consoleUI/console.pas

core: core/constants.pas core/structures.pas core/game.pas
	$(COMP) core/structures.pas
	$(COMP) core/constants.pas
	$(COMP) core/game.pas
