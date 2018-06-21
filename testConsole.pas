PROGRAM testConsole;

USES console2, UIGraphic, structures, constants, game, crt, glib2d, SDL_TTF , sysutils, legal, pAI;

FUNCTION hasWon(g : grille; VAR joueur : typeJoueur) : BOOLEAN;
BEGIN
	IF (getPiocheSize = 0) AND (length(joueur.main) = 0) THEN
	BEGIN
		hasWon := True;
		joueur.score := joueur.score + 6;
	END
	ELSE
	BEGIN
		hasWon := False;
	END;
END;

FUNCTION mainLoop(VAR g : grille; VAR joueur : typeJoueur; coup : typeCoup;VAR  antiBoucleInf :  INTEGER; VAR isFirst : BOOLEAN) : BOOLEAN;
VAR
	i, nombreCoups, lastSize : INTEGER;
	t, score : tabPos;
	tabPions : tabPion;
	finalEtat : BOOLEAN;
BEGIN
	score := initTabPos;
	IF (NOT joueur.genre AND (coup.pos[0].x <> 0)) OR (joueur.genre) AND (length(coup.pos) <> length(coup.p)) THEN
	BEGIN
		t := initTabPos;
		tabPions := initTabPion;
		nombreCoups := 1;
		FOR i := 0 TO length(coup.p) - 1 DO
		BEGIN
			choperPos(t, coup.pos[i].x, coup.pos[i].y, nombreCoups);
			choperPion(tabPions, i, coup.p[i]);
			IF (nCoups(g, t, tabPions, nombreCoups) AND (g[coup.pos[i].x, coup.pos[i].y].couleur = 0)) OR isFirst THEN
			BEGIN
				ajouterPion(g, coup.p[i], coup.pos[i].x, coup.pos[i].y, '');
				choperPos(score, coup.pos[i].x, coup.pos[i].y, nombreCoups);
				removePionFromMain(joueur.main, coup.p[i]);
				inc(nombreCoups);
				isFirst := False;
				finalEtat := True;
			END;
		END;
	END
	ELSE
	BEGIN
		IF (coup.pos[0].x <> -1) THEN
		BEGIN
			FOR i := 0 TO length(joueur.main) - 1 DO
			BEGIN
				IF getPiocheSize - 1 >= 0 THEN
					echangerPion(joueur.main, joueur.main[i]);
			END;
		END
		ELSE
		BEGIN
			FOR i := 0 TO length(coup.p) - 1 DO
			BEGIN
				IF getPiocheSize - 1 >= 0 THEN
					echangerPion(joueur.main, coup.p[i]);
			END;
		END
	END;
	
	joueur.score := joueur.score + point(g, score, nombreCoups);

	IF point(g, score, nombreCoups) = 0 THEN
	BEGIN
		inc(antiBoucleInf);
		finalEtat := False;
	END
	ELSE
	BEGIN
		antiBoucleInf := 0;
	END;

	lastSize := length(joueur.main);
	
	FOR i := 0 TO 6 - lastSize - 1 DO
	BEGIN
		IF getPiocheSize - 1 >= 0 THEN
		BEGIN
			setLength(joueur.main, length(joueur.main) + 1);
			joueur.main[lastSize + i] := piocher;
		END;
	END;
	
	writeln(finalEtat);
	mainLoop := finalEtat;
END;

VAR 
	i, joueurJouant, tmpMachine, tmpHumain, antiBoucleInf : INTEGER;
	nbrJoueurHumain, nbrJoueurMachine, nbrCouleurs, nbrFormes, nbrTuiles : INTEGER;
	allJoueur : tabJoueur;
	g : grille;
	coup : typeCoup;
	isFirst, tests : BOOLEAN;
BEGIN
	
	nbrCouleurs := 6;
	nbrFormes   := 6;
	nbrTuiles   := 3;

	writeln('humain ?');
	readln(nbrJoueurHumain);
	writeln('machine ?');
	readln(nbrJoueurMachine);

	// on creer la pioche
	initPioche(nbrCouleurs, nbrFormes, nbrTuiles);
	initLegal(nbrFormes - 1);
	initJoueur(nbrJoueurHumain, nbrJoueurMachine);
	g := remplirGrille;
	shufflePioche;

	joueurJouant := -1;

	// on creer les mains
	setLength(allJoueur, nbrJoueurHumain + nbrJoueurMachine);
	tmpHumain := nbrJoueurHumain;
	tmpMachine := nbrJoueurMachine;
	
	FOR i := 0 TO nbrJoueurHumain + nbrJoueurMachine - 1 DO
	BEGIN
		IF tmpHumain > 0 THEN
		BEGIN
			allJoueur[i].main  := creerMain;
			allJoueur[i].genre := True;
			allJoueur[i].score := 0;
			dec(tmpHumain);
		END
		ELSE
		BEGIN
			IF tmpMachine > 0 THEN
			BEGIN
				allJoueur[i].main  := creerMain;
				allJoueur[i].genre := False;
				allJoueur[i].score := 0;
				dec(tmpMachine);
			END;
		END;
	END;
	
	antiBoucleInf := 0;
	isFirst := True;
	joueurJouant := -1;
	
	loadImagePion;
    
    // boucle principale
    WHILE (NOT ((antiBoucleInf > 20) OR hasWon(g, allJoueur[joueurJouant]))) DO
    BEGIN
		inc(joueurJouant);
		joueurJouant := joueurJouant MOD (nbrJoueurHumain + nbrJoueurMachine);
		
		gClear(WHITE);
		
		//mainLoop(g, allJoueur, joueurJouant, antiBoucleInf, isFirst);
		
		renderGrilleUI(g);
		
		REPEAT
			IF allJoueur[joueurJouant].genre THEN
			BEGIN
				coup := faireJoueurJoueur(g, allJoueur[joueurJouant].main);
				writeln('fin du tour joueur humain');
			END
			ELSE
			BEGIN
				coup := coupAIPaul(g, allJoueur[joueurJouant].main);
				writeln('fin du tour joueur AI');
			END;
			tests := mainLoop(g, allJoueur[joueurJouant], coup, antiBoucleInf, isFirst);
			writeln('Resultat de mainLoop : ', tests);
		UNTIL tests;
		
		writeln('WTF');
		isFirst := False;
		
		gFlip();
		
        while (sdl_update = 1) do
			if (sdl_do_quit) then
				exit;
    END;
    
    writeln('FIN DU JEU');
    
    WHILE TRUE DO
	BEGIN
		
		gFlip();
		
		while (sdl_update = 1) do
			if (sdl_do_quit) then
				exit;
    END;
END.
