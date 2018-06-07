COMP=fpc
FLAGS=
EXEC=qwirkle

all:
	$(COMP) main.pas

test: 
	$(COMP) test.pas
