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

PROCEDURE mainLoop(VAR g : grille;VAR allJoueur : tabJoueur; VAR joueurJouant, antiBoucleInf : INTEGER; isFirst : BOOLEAN);
VAR
	i, nombreDeCoups, lastSize : INTEGER;
	tabPions : tabPion;
	t,score : tabPos;
	coupsIA  : typeCoup;
	pionAEchanger : tabPion;
	pos : position;
	p : pion;
BEGIN

		t := initTabPos;
		score := initTabPos;
		tabPions := initTabPion;
		nombreDeCoups := 1;

		writeln('dans IA');
		coupsIA := coupAIPaul(g, allJoueur[joueurJouant].main);
		writeln('apres IA');
		IF coupsIA.pos[0].x <> -1 THEN
		BEGIN
			FOR i := 0 TO length(coupsIA.p) - 1 DO
			BEGIN
				p := coupsIA.p[i];
				pos := coupsIA.pos[i];
				choperPos(t, pos.x, pos.y, nombreDeCoups);
				choperPion(tabPions, nombreDeCoups, p);
				IF (nCoups(g, t, tabPions, nombreDeCoups) AND (g[pos.x, pos.y].couleur = 0) AND (nombreDeCoups < 6)) OR isFirst THEN
				BEGIN
					ajouterPion(g, p, pos.x, pos.y, intToStr(joueurJouant));
					choperPos(score, pos.x, pos.y, nombreDeCoups);
					removePionFromMain(allJoueur[joueurJouant].main, p);
					inc(nombreDeCoups);
					isFirst := False;
				END;
			END;
		END
		ELSE
		BEGIN
			FOR i := 0 TO length(allJoueur[joueurJouant].main) - 1 DO
			BEGIN
				IF getPiocheSize - 1 >= 0 THEN
					echangerPion(allJoueur[joueurJouant].main, allJoueur[joueurJouant].main[i]);
			END;
		END;

		allJoueur[joueurJouant].score := allJoueur[joueurJouant].score + point(g, score, nombreDeCoups);
		IF point(g, score, nombreDeCoups) = 0 THEN
			inc(antiBoucleInf)
		ELSE
			antiBoucleInf := 0;

		lastSize := length(allJoueur[joueurJouant].main);
		
		FOR i := 0 TO 6 - lastSize - 1 DO
		BEGIN
			IF getPiocheSize - 1 >= 0 THEN
			BEGIN
				setLength(allJoueur[joueurJouant].main, length(allJoueur[joueurJouant].main) + 1);
				allJoueur[joueurJouant].main[lastSize + i] := piocher;
			END;
		END;
END;

VAR 
	i, ii, joueurJouant, nombreDeCoups, lastSize, tmpMachine, tmpHumain, index, antiBoucleInf : INTEGER;
	nbrJoueurHumain, nbrJoueurMachine, nbrCouleurs, nbrFormes, nbrTuiles : INTEGER;
	allJoueur : tabJoueur;
	g, tmpGrille : grille;
	p : pion;
	coup : typeCoup;
	stop, aFiniDeJouer, isFirst, nCoupss : BOOLEAN;
	responce : CHAR;
	taille, length : INTEGER;
    font : PTTF_Font;
    text_image : gImage;
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
	
	stop := False;
    WHILE (NOT ((antiBoucleInf > 20) OR hasWon(g, allJoueur[joueurJouant]))) DO
    BEGIN
		inc(joueurJouant);
		joueurJouant := joueurJouant MOD (nbrJoueurHumain + nbrJoueurMachine);
		
		gClear(WHITE);
		
		mainLoop(g, allJoueur, joueurJouant, antiBoucleInf, isFirst);
		isFirst := False;
		
		renderGrille(g);
		renderMainUI(allJoueur[joueurJouant].main);
		
		supprimerPion(g, allJoueur[joueurJouant].main);
		
		
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
