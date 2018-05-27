COMP=fpc
FLAGS=
EXEC=qwirkle

all: legal uix core
	$(COMP) main.pas

# legal: legal/legal.pas
# 	$(COMP) legal/legal.pas

uix: uix/consoleUI/console.pas
	$(COMP) uix/consoleUI/console.pas

core: core/constants.pas core/game.pas core/structures.pas
	$(COMP) core/structures.pas
	$(COMP) core/constants.pas
	$(COMP) core/game.pas
