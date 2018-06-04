PROGRAM main;

USES console in 'uix/consoleUI/console.pas', crt,
	constants in 'core/constants.pas',
	structures in 'core/structure.pas',
	game in 'core/game.pas',
	legal in 'legal/legal.pas';

VAR
	p : pion;
	pos : position;
	g : grille;
	i : INTEGER;
	mainJoueur1, mainJoueur2 : mainJoueur;
	isFirst : BOOLEAN;
BEGIN
	i := 0;
	initConsole;
	g := remplirGrille;
	clrscr;
	clearScreen(COL_BLACK);
	initPioche;
	shufflePioche;
	mainJoueur1 := creerMain;
	mainJoueur2 := creerMain;
	isFirst := True;
	// boucle principale du jeu de ouff
	REPEAT
		clearScreen(COL_BLACK);
		renderMenuBorder;
		render;
		renderGame(g);
		IF i MOD 2 = 0 THEN
		BEGIN
			p := selectorMain(mainJoueur1);
			isFirst := False;
		END
		ELSE
			p := selectorMain(mainJoueur2);

		IF p.couleur = COULEUR_NULL THEN
		BEGIN
			IF i MOD 2 = 0 THEN echangerPioche(mainJoueur1);
			IF i MOD 2 = 1 THEN echangerPioche(mainJoueur2);
		END;
		pos := selectorPos(g);
		IF isLegal(g, pos.x, pos.y, p, isFirst) THEN
		BEGIN
			ajouterPion(g, p, pos.x - 2, pos.y - 2, 'J1');
			IF i MOD 2 = 0 THEN
				removePionFromPioche(mainJoueur1, p)
			ELSE
				removePionFromPioche(mainJoueur2, p);
			inc(i);
		END
		ELSE
		BEGIN
			clrscr;
			writeln('Tu peux pas placer la.');
		END;

	UNTIL ((hasWon) or (readKey = #27));
END.
