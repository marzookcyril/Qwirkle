PROGRAM test;
USES console in 'uix/consoleUI/console.pas', crt,
	constants in 'core/constants.pas',
	structures in 'core/structure.pas',
	game in 'core/game.pas';

VAR
	pioche : typePioche;
	i, y : INTEGER;
BEGIN
	pioche := initPioche;
	initConsole;
	clearScreen(0);
	writeln('PIOCHE NON MELANGEE:');
	FOR i := 0 TO 105 DO
	BEGIN
		writeln(i);
		renderPion((i*2) MOD WIDTH - 1, (i*2) MOD HEIGHT - 1, pioche[i]);
	END;
	render;
END.
