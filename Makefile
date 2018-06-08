COMP=./fpc-3.0.4/bin/fpc
FLAGS=
EXEC=qwirkle

all:
	$(COMP) main.pas

test: 
	$(COMP) test.pas
