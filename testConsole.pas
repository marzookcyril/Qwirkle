PROGRAM testConsole;

USES console2, structures, constants, game, crt;

VAR
	g : grille;
	i, j : INTEGER;
	mainTest : tabPion;
	test : tabPion;
BEGIN
	setLength(g, 20, 20);
	
	FOR i := 0 TO length(g) - 1 DO
	BEGIN
		FOR j := 0 TO length(g) - 1 DO
		BEGIN
			g[i,j].forme   := i MOD 10 + 1;
			g[i,j].couleur := j MOD 10 + 1;
		END;
	END;
	
	renderGrille(g);
	initPioche(3, 6, 6);
	initConsole(g);
	mainTest := creerMain;
	test := multiplePionSelector(g, mainTest);
	
	FOR i := 0 TO length(test) - 1 DO
		writeln(test[i].couleur);
END.
