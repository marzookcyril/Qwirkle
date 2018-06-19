PROGRAM main;
USES crt, sysutils, game, console2, structures, legal, constants, pAI;

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

VAR
	i, ii, joueurJouant, nombreDeCoups, lastSize, tmpMachine, tmpHumain, index, antiBoucleInf : INTEGER;
	nbrJoueurHumain, nbrJoueurMachine, nbrCouleurs, nbrFormes, nbrTuiles : INTEGER;
	allJoueur : tabJoueur;
	pos : position;
	g, tmpGrille : grille;
	p : pion;
	stop, aFiniDeJouer, isFirst, nCoupss : BOOLEAN;
	t,score : tabPos;
	responce : CHAR;
	tabPions : tabPion;
	coupsIA  : typeCoup;
	pionAEchanger : tabPion;
BEGIN
	// initialisation des variables, on est jamais trop prudent avec
	// pascal <3
	nbrCouleurs      := 0;
	nbrFormes        := 0;
	nbrTuiles        := 0;
	nbrJoueurHumain  := 0;
	nbrJoueurMachine := 0;

	stop := False;

	// on va initialiser le jeu avec les parametres pris en compte
	FOR i := 0 TO ParamCount - 1 DO
	BEGIN
		CASE ParamStr(i) OF
			'-j' :
				BEGIN
					FOR ii := 0 TO length(ParamStr(i+1)) DO
					BEGIN
						CASE ParamStr(i+1)[ii] OF
							'h': inc(nbrJoueurHumain);
							'o': inc(nbrJoueurMachine);
						END;
					END;
				END;
			'-c' : nbrCouleurs := strtoint(ParamStr(i+1));
			'-f' : nbrFormes   := strtoint(ParamStr(i+1));
			'-t' : nbrTuiles   := strtoint(ParamStr(i+1));
		END;
	END;

	writeln('Parametres : ', nbrJoueurHumain, nbrJoueurMachine, nbrCouleurs, nbrFormes, nbrTuiles);

	// si les parametres sont vides, on mets les parametres par defaut
	IF nbrCouleurs      = 0 THEN nbrCouleurs      := 6;
	IF nbrFormes        = 0 THEN nbrFormes        := 6;
	IF nbrTuiles        = 0 THEN nbrTuiles        := 5;

	IF nbrJoueurHumain + nbrJoueurMachine = 0 THEN
	BEGIN
		writeln('humain ?');
		readln(nbrJoueurHumain);
		writeln('machine ?');
		readln(nbrJoueurMachine);
	END;

	
	// on creer la pioche
	initPioche(nbrCouleurs, nbrFormes, nbrTuiles);
	initLegal(nbrFormes - 1);
	initJoueur(nbrJoueurHumain, nbrJoueurMachine);
	g := remplirGrille;
	initConsole(g);
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

	isFirst := True;
	
	index := 0;
	antiBoucleInf := 0;
	
	REPEAT
		//renderText('Taille pioche :' + inttostr(getPiocheSize), 40, getHeight - 3, COL_WHITE, COL_BLACK);
		clrscr;
		lastSize := 0;
		inc(joueurJouant);
		joueurJouant := joueurJouant MOD (nbrJoueurHumain + nbrJoueurMachine);
		renderTextWillFullBordure('Tour du joueur ' + inttostr(joueurJouant) + '...');
		inc(index);
		// on fait jouer le joueur humain / machine
		IF allJoueur[joueurJouant].genre THEN
		BEGIN
			nombreDeCoups := 1;
			t := initTabPos;
			tabPions := initTabPion;
			renderGrille(g);
			renderMain(allJoueur[joueurJouant].main);
			IF renderPopUpWithResponce('Changer votre pioche ? (o/n)') = 'o' THEN
			BEGIN
				pionAEchanger := multiplePionSelector(g, allJoueur[joueurJouant].main);
				FOR i := 0 TO length(pionAEchanger) - 1 DO
				BEGIN
					echangerPion(allJoueur[joueurJouant].main, pionAEchanger[i]);
				END;
			END
			ELSE
			BEGIN
				REPEAT
					aFiniDeJouer := True;
					p := mainSelector(g, allJoueur[joueurJouant].main);
					IF NOT isFirst THEN
					BEGIN
						pos := posSelector(g, allJoueur[joueurJouant].main);
					END
					ELSE
					BEGIN
						pos.x := length(g) DIV 2;
						pos.y := length(g) DIV 2;
					END;
					clrscr;
					choperPos(t, pos.x, pos.y, nombreDeCoups);
					choperPion(tabPions, nombreDeCoups, p);
					nCoupss := nCoups(g, t, tabPions, nombreDeCoups);
					IF (nCoupss AND (g[pos.x, pos.y].couleur = 0)) OR isFirst THEN
					BEGIN
						ajouterPion(g, p, pos.x, pos.y, intToStr(joueurJouant));
						removePionFromMain(allJoueur[joueurJouant].main, p);
						renderGrille(g);
						responce := renderPopUpWithResponce('Un autre pion ?');
						isFirst := False;
						IF responce = 'o' THEN
						BEGIN
							inc(nombreDeCoups);
							aFiniDeJouer := False;
						END
						ELSE
						BEGIN
							aFiniDeJouer := True;
						END;
					END
					ELSE
					BEGIN
						renderTextWithBordure('Pas possible de jouer la');
						responce := renderPopUpWithResponce('Un autre pion ?');
						IF responce = 'o' THEN
							aFiniDeJouer := False
						ELSE
							aFiniDeJouer := True;
					END;
				UNTIL aFiniDeJouer;

				allJoueur[joueurJouant].score := allJoueur[joueurJouant].score + point(g, t, nombreDeCoups);
				renderScore(allJoueur);
				renderGrille(g);

				lastSize := length(allJoueur[joueurJouant].main);
				FOR i := 0 TO 6 - lastSize - 1 DO
				BEGIN
					IF getPiocheSize + 1 < maxPiocheSize THEN
					BEGIN
						setLength(allJoueur[joueurJouant].main, length(allJoueur[joueurJouant].main) + 1);
						allJoueur[joueurJouant].main[lastSize + i] := piocher;
					END;
				END;
			END;
		END
		ELSE
		BEGIN
			t := initTabPos;
			score := initTabPos;
			tabPions := initTabPion;
			nombreDeCoups := 1;

			// on recupere tous les coups de l'IA
			//writeln('----------');
			//writeln('Je suis la');
			coupsIA := coupAIPaul(g, allJoueur[joueurJouant].main);
			//writeln('Je suis laa');
			//writeln('==========');
			renderMain(allJoueur[joueurJouant].main);
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
			
			renderScore(allJoueur);
			renderGrille(g);

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
		writeln((antiBoucleInf < 10));
	UNTIL ((antiBoucleInf > 10) OR hasWon(g, allJoueur[joueurJouant]));
	
	clrscr;
	renderScore(allJoueur);
	renderGrille(g);
	
	FOR i := 0 TO length(allJoueur) - 1 DO
		IF allJoueur[i].score > lastSize THEN
		BEGIN
			joueurJouant := i;
			lastSize := allJoueur[i].score;
		END;	
	renderPopUpWithResponce('fin de la partie, le gagnant est : ' + inttostr(joueurJouant));
	clrscr;
END.
