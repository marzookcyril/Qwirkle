COMP=fpc
FLAGS=
EXEC=qwirkle

all: core/constants.pas core/game.pas core/structures.pas uix/consoleUI/console.pas
	$(COMP) core/constants.pas core
