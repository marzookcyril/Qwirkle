PROGRAM Qwirkle;

USES crt, sysutils, game, console2, structures, legal, constants, pAI, UIGraphic, glib2d;

VAR
	iaBloque : INTEGER = 0;

FUNCTION isFirst(g : grille) : BOOLEAN;
VAR
	i, j : INTEGER;
BEGIN
	isFirst := True;
	FOR i := 0 TO length(g) - 1 DO
	BEGIN
		FOR j := 0 TO length(g) - 1 DO
		BEGIN
			IF g[i,j].couleur <> 0 THEN
				isFirst := False;
		END;
	END;
END;

FUNCTION mainVide(main : tabPion) : INTEGER;
VAR
	i : INTEGER;
BEGIN
	mainVide := 0;
	FOR i := 0 TO length(main) - 1 DO
	BEGIN
		IF main[i].couleur <> 0 THEN
			inc(mainVide);
	END;
END;

FUNCTION hasWon(g : grille; VAR joueur : typeJoueur) : BOOLEAN;
BEGIN
	IF (getPiocheSize = 0) AND ((length(joueur.main) = 0) OR (joueur.main[0].couleur = 0)) THEN
	BEGIN
		hasWon := True;
		joueur.score := joueur.score + 6;
	END
	ELSE
		hasWon := False;
END;

FUNCTION createArgs : typeArgs;
VAR
	i, ii : INTEGER;
BEGIN
	createArgs.graphique := True;
	createArgs.couleurs  := 0;
	createArgs.formes    := 0;
	createArgs.tuiles    := 0;
	createArgs.humains   := 0;
	createArgs.machines  := 0;
	FOR i := 1 TO ParamCount DO
	BEGIN
		CASE ParamStr(i) OF
			'-j' :
				BEGIN
					FOR ii := 0 TO length(ParamStr(i+1)) DO
					BEGIN
						CASE ParamStr(i+1)[ii] OF
							'h': inc(createArgs.humains);
							'o': inc(createArgs.machines);
						END;
					END;
				END;
			'-c' : createArgs.couleurs  := strtoint(ParamStr(i+1));
			'-f' : createArgs.formes    := strtoint(ParamStr(i+1));
			'-t' : createArgs.tuiles    := strtoint(ParamStr(i+1));
			'-g' : createArgs.graphique := True;
		END;
	END;
	
	IF createArgs.couleurs      = 0 THEN createArgs.couleurs      := 6;
	IF createArgs.formes        = 0 THEN createArgs.formes        := 6;
	IF createArgs.tuiles        = 0 THEN createArgs.tuiles        := 6;
	
	IF createArgs.humains + createArgs.machines = 0 THEN
	BEGIN
		createArgs.humains  := 0;
		createArgs.machines := 2;
	END;
	
	IF ((createArgs.couleurs > 6) OR (createArgs.formes > 6)) AND createArgs.graphique THEN
	BEGIN
		writeln('L''interface graphique supporte que 6 formes et 6 couleurs.');
		Halt (1);
	END;
	
	IF (createArgs.couleurs > 10) OR (createArgs.formes > 10) or (createArgs.tuiles > 10) or (createArgs.humains + createArgs.machines > 10) THEN
	BEGIN
		writeln('Votre configuration n''est pas possible. Au maximum, vous pouvez jouer avec 10 tuiles, 10 couleurs, 10 formes et 10 joueurs');
		Halt (1);
	END;
	
	createArgs := createArgs;
END;

FUNCTION createJoueur (humain, machine : INTEGER) : tabJoueur;
VAR
	i : INTEGER;
BEGIN
	setLength(createJoueur, humain + machine);
	FOR i := 0 TO humain + machine - 1 DO
	BEGIN
		IF humain > 0 THEN
		BEGIN
			createJoueur[i].main  := creerMain;
			createJoueur[i].genre := True;
			createJoueur[i].score := 0;
			dec(humain);
		END
		ELSE
		BEGIN
			IF machine > 0 THEN
			BEGIN
				createJoueur[i].main  := creerMain;
				createJoueur[i].genre := False;
				createJoueur[i].score := 0;
				dec(machine);
			END;
		END;
	END;
END;

PROCEDURE mettreAJourMain(VAR main : tabPion);
VAR
	lastSize, i : INTEGER;
BEGIN
	lastSize := length(main);
	FOR i := 0 TO 6 - lastSize - 1 DO
	BEGIN
		IF getPiocheSize + 1 < maxPiocheSize THEN
		BEGIN
			setLength(main, length(main) + 1);
			main[lastSize + i] := piocher;
		END;
	END;
END;

PROCEDURE faireJouerMachineModeConsole(VAR g : grille; VAR allJoueur : tabJoueur; joueurJouant : INTEGER; isFirst : BOOLEAN);
VAR
	nombreDeCoups, i : INTEGER;
	tabPosi, tabScore : tabPos;
	tabPions : tabPion;
	joueur : typeJoueur;
	p : pion;
	pos : position;
	coupsIA  : typeCoup;
BEGIN
	clrScr;
	joueur := allJoueur[joueurJouant];
	tabPosi   := initTabPos;
	tabPions  := initTabPion;
	tabScore  := initTabPos;
	nombreDeCoups := 1;
	
	renderTextWillFullBordure('Tour de la machine ' + inttostr(joueurJouant) + '...');
	
	renderScore(allJoueur);
	renderGrille(g);
	renderMain(joueur.main);
	
	coupsIA := coupAIPaul(g, allJoueur[joueurJouant].main);
	
	FOR i := 0 TO length(coupsIA.p) - 1 DO
	BEGIN
		p := coupsIA.p[i];
		pos := coupsIA.pos[i];
		choperPos(tabPosi, pos.x, pos.y, nombreDeCoups);
		choperPion(tabPions, nombreDeCoups, p);
		IF (nCoups(g, tabPosi, tabPions, nombreDeCoups) AND (g[pos.x, pos.y].couleur = 0) AND ((p.forme <> 0) OR (p.couleur <> 0))) OR isFirst THEN
		BEGIN
			ajouterPion(g, p, pos.x, pos.y);
			choperPos(tabScore, pos.x, pos.y, nombreDeCoups);
			removePionFromMain(joueur.main, p);
			inc(nombreDeCoups);
			isFirst := False;
		END;
	END;
	
	IF point(g, tabScore, nombreDeCoups) = 0 THEN
	BEGIN
		IF getPiocheSize = 0 THEN
		BEGIN
			writeln('L''IA NE PEUT RIEN FAIRE');
			inc(iaBloque);
		END;
		FOR i := 0 TO length(joueur.main) - 1 DO
		BEGIN
			IF getPiocheSize - 1 >= 0 THEN
				echangerPion(joueur.main, joueur.main[i]);
		END;
	END
	ELSE
	BEGIN
		clrScr;
		joueur.score += point(g, tabScore, nombreDeCoups);
		renderScore(allJoueur);
		renderGrille(g);

		mettreAJourMain(joueur.main);
	END;
	
	
	allJoueur[joueurJouant] := joueur;	
END;

PROCEDURE faireJouerHumainModeConsole(VAR g : grille;VAR allJoueur : tabJoueur; joueurJouant : INTEGER; isFirst : BOOLEAN);
VAR
	hasPlayed : BOOLEAN;
	nombreDeCoups, i : INTEGER;
	tabPosi, tabScore : tabPos;
	tabPions : tabPion;
	joueur : typeJoueur;
	p : pion;
	pos : position;
BEGIN
	clrScr;
	joueur := allJoueur[joueurJouant];
	hasPlayed := False;
	tabPosi   := initTabPos;
	tabPions  := initTabPion;
	tabScore  := initTabPos;
	nombreDeCoups := 1;
	
	renderTextWillFullBordure('Tour du joueur ' + inttostr(joueurJouant) + '...');
	
	renderScore(allJoueur);
	renderGrille(g);
	renderMain(joueur.main);
	
	IF renderPopUpWithResponce('Changer votre pioche ? (o/n)') = 'o' THEN
	BEGIN
		setLength(tabPions, 0);
		tabPions := multiplePionSelector(g, joueur.main);
		FOR i := 0 TO length(tabPions) - 1 DO
			echangerPion(joueur.main, tabPions[i]);
	END
	ELSE
	BEGIN
		REPEAT
			clrScr;
			p := mainSelector(g, joueur.main);
			IF NOT isFirst THEN
				pos := posSelector(g, joueur.main)
			ELSE
			BEGIN
				pos.x := length(g) DIV 2;
				pos.y := length(g) DIV 2;
			END;
			
			clrscr;
			choperPos(tabPosi, pos.x, pos.y, nombreDeCoups);
			choperPion(tabPions, nombreDeCoups, p);
			
			// on regarde si le coup est valide
			IF (nCoups(g, tabPosi, tabPions, nombreDeCoups) AND (g[pos.x, pos.y].couleur = 0)) OR isFirst THEN
			BEGIN
				ajouterPion(g, p, pos.x, pos.y);
				removePionFromMain(joueur.main, p);
				clrScr;
				renderGrille(g);
				choperPos(tabScore, pos.x, pos.y, nombreDeCoups);
				isFirst := False;
				
				IF renderPopUpWithResponce('Un autre pion ?') = 'o' THEN
				BEGIN
					hasPlayed := False;
					inc(nombreDeCoups);
				END
				ELSE
					hasPlayed := True;
			END
			ELSE
			BEGIN
				renderTextWithBordure('Pas possible de jouer la');
				IF renderPopUpWithResponce('Un autre pion ?') = 'o' THEN
					hasPlayed := False
				ELSE
					hasPlayed := True;
			END;
		UNTIL hasPlayed;
		// le joueur a fini de jouer, on increment son score et met à jour sa main
		
		clrScr;
		joueur.score := joueur.score + point(g, tabScore, nombreDeCoups);
		renderScore(allJoueur);
		renderGrille(g);
		
		mettreAJourMain(joueur.main);
		
		allJoueur[joueurJouant] := joueur;
	END;
END;

PROCEDURE faireJouerMachineModeGraphique(VAR g : grille; VAR allJoueur : tabJoueur; joueurJouant : INTEGER; isFirst : BOOLEAN);
VAR
	nombreDeCoups, i : INTEGER;
	tabPosi, tabScore : tabPos;
	tabPions : tabPion;
	joueur : typeJoueur;
	p : pion;
	pos : position;
	coupsIA  : typeCoup;
BEGIN
	joueur := allJoueur[joueurJouant];
	tabPosi   := initTabPos;
	tabPions  := initTabPion;
	tabScore  := initTabPos;
	nombreDeCoups := 1;
	
{
	clearScreen;
	renderScoreUI(allJoueur, joueurJouant);
	renderGrilleUI(g);
	gFlip;
	
}
	coupsIA := coupAIPaul(g, allJoueur[joueurJouant].main);
	
	FOR i := 0 TO length(coupsIA.p) - 1 DO
	BEGIN
		p := coupsIA.p[i];
		pos := coupsIA.pos[i];
		choperPos(tabPosi, pos.x, pos.y, nombreDeCoups);
		choperPion(tabPions, nombreDeCoups, p);
		IF (nCoups(g, tabPosi, tabPions, nombreDeCoups) AND (g[pos.x, pos.y].couleur = 0) AND ((p.forme <> 0) OR (p.couleur <> 0))) OR isFirst THEN
		BEGIN
			ajouterPion(g, p, pos.x, pos.y);
			choperPos(tabScore, pos.x, pos.y, nombreDeCoups);
			removePionFromMain(joueur.main, p);
			inc(nombreDeCoups);
			isFirst := False;
		END;
	END;

	IF point(g, tabScore, nombreDeCoups) = 0 THEN
	BEGIN
		IF getPiocheSize = 0 THEN
		BEGIN
			writeln('L''IA NE PEUT RIEN FAIRE');
			inc(iaBloque);
		END;
		FOR i := 0 TO length(joueur.main) - 1 DO
		BEGIN
			IF getPiocheSize - 1 > 0 THEN
				echangerPion(joueur.main, joueur.main[i]);
		END;
	END;
		
	joueur.score := joueur.score + point(g, tabScore, nombreDeCoups);
	
	clearScreen;
	renderGrilleUI(g);
	renderScoreUI(allJoueur, joueurJouant);
	gFlip();
	
	mettreAJourMain(joueur.main);
	
	allJoueur[joueurJouant] := joueur;	
END;

PROCEDURE faireJouerHumainModeGraphique(VAR g : grille; VAR allJoueur : tabJoueur; joueurJouant : INTEGER; isFirst : BOOLEAN);
VAR
	nombreDeCoups, i : INTEGER;
	tabPosi, tabScore : tabPos;
	tabPions : tabPion;
	joueur : typeJoueur;
	p : pion;
	oldGrille : grille;
	oldMain   : tabPion;
	pos : position;
	coups  : typeCoup;
	erreur, wasFirst : BOOLEAN;
BEGIN
	oldGrille := copyGrille(g);
	oldMain   := copyMain(allJoueur[joueurJouant].main);
	wasFirst  := isFirst;
	joueur := allJoueur[joueurJouant];
	tabPosi   := initTabPos;
	tabPions  := initTabPion;
	tabScore  := initTabPos;
	nombreDeCoups := 1;
	erreur := False;
	
	clearScreen;
	renderGrilleUI(g);
	gFlip;
	
	coups := faireJoueurJoueur(g, allJoueur[joueurJouant].main, allJoueur, joueurJouant, isFirst);
	
	IF length(coups.p) = length(coups.pos) THEN
	BEGIN
		writeln(length(coups.p));
		FOR i := 0 TO length(coups.p) - 1 DO
		BEGIN
			p := coups.p[i];
			pos := coups.pos[i];
			choperPos(tabPosi, pos.x - 1, pos.y - 1, nombreDeCoups);
			choperPion(tabPions, nombreDeCoups, p);
			
			IF (nCoups(g, tabPosi, tabPions, nombreDeCoups) AND (g[pos.x - 1, pos.y - 1].couleur = 0)) OR isFirst THEN
			BEGIN
				ajouterPion(g, p, pos.x - 1, pos.y - 1);
				choperPos(tabScore, pos.x - 1, pos.y - 1, nombreDeCoups);
				removePionFromMain(joueur.main, p);
				inc(nombreDeCoups);
				isFirst := False;
			END
			ELSE
				erreur := True;
		END;
	END
	ELSE
	BEGIN
		FOR i := 0 TO length(coups.p) - 1 DO
		BEGIN
			IF getPiocheSize - 1 > 0 THEN
				echangerPion(joueur.main, coups.p[i]);
		END;
	END;
	
	IF erreur THEN
	BEGIN
		joueur.main := copyMain(oldMain);
		g := copyGrille(oldGrille);
		isFirst := wasFirst;
		clearScreen;
		afficherText('Tu ne peux pas joueur la...', 650, 425, 4, RED);
		gFlip;
		delay(1500);
		faireJouerHumainModeGraphique(g, allJoueur, joueurJouant, isFirst);
	END
	ELSE
	BEGIN
		joueur.score := joueur.score + point(g, tabScore, nombreDeCoups);
		
		clearScreen;
		renderGrilleUI(g);
		gFlip();
		
		mettreAJourMain(joueur.main);
		
		allJoueur[joueurJouant] := joueur;	
	END;
END;

VAR
	gameArgs : typeArgs;
	g : grille;
	allJoueur : tabJoueur;
	joueurJouant, scoreTemp, i : INTEGER;
	isFirstToPlay : BOOLEAN;
BEGIN
	gameArgs := createArgs;
	initPioche(gameArgs.couleurs, gameArgs.formes, gameArgs.tuiles);
	initLegal(gameArgs.formes);
	initJoueur(gameArgs.humains, gameArgs.machines);
	
	g := remplirGrille;
	
	initConsole(g);
	shufflePioche;
	
	allJoueur := createJoueur(gameArgs.humains, gameArgs.machines);
	joueurJouant := -1;
	
	IF gameArgs.graphique THEN
	BEGIN
		loadImagePion;
		clearScreen;
	END;
	
	REPEAT
		isFirstToPlay := isFirst(g);
	
		inc(joueurJouant);
		joueurJouant := joueurJouant MOD (gameArgs.humains + gameArgs.machines);
		
		// on joue en mode graphique
		IF gameArgs.graphique THEN
		BEGIN
			gFlip();
			WHILE (sdl_update = 1) DO
				IF (sdl_do_quit) THEN
					exit; 
					
			IF allJoueur[joueurJouant].genre THEN faireJouerHumainModeGraphique(g, allJoueur, joueurJouant, isFirstToPlay)
			ELSE								  faireJouerMachineModeGraphique(g, allJoueur, joueurJouant, isFirstToPlay);
		END
		ELSE // on joue en mode console
		BEGIN
			IF allJoueur[joueurJouant].genre THEN faireJouerHumainModeConsole(g, allJoueur, joueurJouant, isFirstToPlay)
			ELSE								  faireJouerMachineModeConsole(g, allJoueur, joueurJouant, isFirstToPlay);
		END;
			
	UNTIL hasWon(g, allJoueur[joueurJouant]) OR (iaBloque > 4);
	// il y a des moments où les IA sont à leur limite et ne peuvent plus jouer...
	
	writeln('FIN DE LA PARTIE');
	scoreTemp := 0;
	
	FOR i := 0 TO length(allJoueur) - 1 DO
	BEGIN
		IF allJoueur[i].score > scoreTemp THEN
		BEGIN
			joueurJouant := i;
			scoreTemp := allJoueur[i].score;
		END;	
	END;
	
	IF gameArgs.graphique THEN
	BEGIN
		WHILE TRUE DO
		BEGIN
			clearScreen;
			IF allJoueur[joueurJouant].genre THEN
				afficherText('Le gagnant est l''humain n ' + inttostr(joueurJouant) + '! gg! (score:' + inttostr(scoreTemp) + ')', 500, 450, 4, RED)
			ELSE
				afficherText('Le gagnant est l''ordi n ' + inttostr(joueurJouant) + '! gg! (score:' + inttostr(scoreTemp) + ')', 500, 450, 4, RED);
				
			gFlip();
			while (sdl_update = 1) do
				if (sdl_do_quit) then
					exit;
		END;
	END
	ELSE
		renderPopUpWithResponce('Fin de la partie, le gagnant est : ' + inttostr(joueurJouant));
	clrscr;
END.
