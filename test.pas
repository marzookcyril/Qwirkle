PROGRAM test;
USES console in 'uix/consoleUI/console.pas', crt, sysutils,
	constants in 'core/constants.pas',
	structures in 'core/structure.pas',
	game in 'core/game.pas';

VAR
	pioche : typePioche;
	i, y : INTEGER;
	g : grille;
BEGIN
	pioche := initPioche;
	shufflePioche(pioche);
	g := remplirGrille;
	initConsole;
	clrscr;
	clearScreen(0);
	renderMenuBorder;
	writeln('PIOCHE NON MELANGEE:');
	FOR i := 0 TO 107 DO
	BEGIN
		ajouterPion(g, pioche[i], i MOD 24, i DIV 24, inttostr(pioche[i].couleur));
		WriteLn(pioche[i].couleur);
	END;
	renderGame(g);
	render;
END.
