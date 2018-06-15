PROGRAM main;
USES crt, sysutils, game, console, structures, legal, constants, pAI;

FUNCTION hasWon(g : grille; VAR joueur : typeJoueur) : BOOLEAN;
BEGIN
	writeln(coupAIPaul(g, joueur.main).pos[0].x);
	IF (getPiocheSize = 0) AND ((length(joueur.main) = 0) OR (coupAIPaul(g, joueur.main).pos[0].x = -1)) THEN
	BEGIN
		hasWon := True;
		joueur.score := joueur.score + 6;
	END
	ELSE
		hasWon := False;
END;

VAR
	i, ii, joueurJouant, nombreDeCoups, lastSize, tmpMachine, tmpHumain : INTEGER;
	nbrJoueurHumain, nbrJoueurMachine, nbrCouleurs, nbrFormes, nbrTuiles : INTEGER;
	allJoueur : tabJoueur;
	pos : position;
	g, tmpGrille : grille;
	p : pion;
	stop, aFiniDeJouer, isFirst : BOOLEAN;
	t : tabPos;
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
	IF nbrTuiles        = 0 THEN nbrTuiles        := 3;

	IF nbrJoueurHumain + nbrJoueurMachine = 0 THEN
	BEGIN
		writeln('humain ?');
		readln(nbrJoueurHumain);
		writeln('machine ?');
		readln(nbrJoueurMachine);
	END;

	initConsole;

	// on creer la pioche
	initPioche(nbrCouleurs, nbrFormes, nbrTuiles);
	initJoueur(nbrJoueurHumain, nbrJoueurMachine);
	g := remplirGrille;
	shufflePioche;
	renderMenuBorder(g);
	renderTitle('Qwirkle par Cyril et Paul :');
	render;

	joueurJouant := -1;

	// on creer les mains
	setLength(allJoueur, nbrJoueurHumain + nbrJoueurMachine + 1);
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
{
	p.couleur := COULEUR_ROUGE;
	p.forme := FORME_TREFLE;
	ajouterPion(g, p, 12,12,'D');
}

	REPEAT
		//renderText('Taille pioche :' + inttostr(getPiocheSize), 40, getHeight - 3, COL_WHITE, COL_BLACK);
		lastSize := 0;
		inc(joueurJouant);
		joueurJouant := joueurJouant MOD (nbrJoueurHumain + nbrJoueurMachine);
		renderTitle('Tour du joueur ' + inttostr(joueurJouant) + '...');
		
		// on fait jouer le joueur humain / machine
		IF allJoueur[joueurJouant].genre THEN
		BEGIN
			renderPopUp('C''est au joueur : ' + inttostr(joueurJouant) + ' de jouer...');
			nombreDeCoups := 1;
			t := initTabPos;
			tabPions := initTabPion;
			renderMain(3, getHeight - 3, joueurJouant, allJoueur[joueurJouant].main);
			render;
			IF renderPopUpWithResponce('Voulez vous changer votre pioche ? (o/n)') = 'o' THEN
			BEGIN
				pionAEchanger := remplacerMain(allJoueur[joueurJouant].main, joueurJouant);
				FOR i := 0 TO length(pionAEchanger) - 1 DO
				BEGIN
					echangerPion(allJoueur[joueurJouant].main, pionAEchanger[i]);
				END;
			END
			ELSE
			BEGIN
				REPEAT
					aFiniDeJouer := True;
					p := selectorMain(allJoueur[joueurJouant].main, joueurJouant);
					IF NOT isFirst THEN
					BEGIN
						pos := selectorPos(g, TAILLE_GRILLE DIV 2, TAILLE_GRILLE DIV 2);
						pos.x := pos.x - 2;
						pos.y := pos.y - 2;
					END
					ELSE
					BEGIN
						pos.x := TAILLE_GRILLE DIV 2;
						pos.y := TAILLE_GRILLE DIV 2;
					END;
					choperPos(t, pos.x, pos.y, nombreDeCoups);
					choperPion(tabPions, nombreDeCoups, p);
					IF (nCoups(g, t, tabPions, nombreDeCoups) AND (g[pos.x, pos.y].couleur = 0)) OR isFirst THEN
					BEGIN
						ajouterPion(g, p, pos.x, pos.y, intToStr(joueurJouant));
						removePionFromMain(allJoueur[joueurJouant].main, p);
						renderGame(g);
						render;
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
						renderPopUp('Pas possible de jouer la');
						responce := renderPopUpWithResponce('Un autre pion ?');
						IF responce = 'o' THEN
							aFiniDeJouer := False
						ELSE
							aFiniDeJouer := True;
					END;
				UNTIL aFiniDeJouer;

				allJoueur[joueurJouant].score := allJoueur[joueurJouant].score + point(g, t, nombreDeCoups);
				//renderScore(joueurJouant, allJoueur[joueurJouant].score);
				renderGame(g);
				//renderHistorique;
				render;

				lastSize := length(allJoueur[joueurJouant].main);
				FOR i := 0 TO 6 - lastSize - 1 DO
				BEGIN
					setLength(allJoueur[joueurJouant].main, length(allJoueur[joueurJouant].main) + 1);
					allJoueur[joueurJouant].main[lastSize + i] := piocher;
				END;
			END;
		END
		ELSE
		BEGIN
			t := initTabPos;
			tabPions := initTabPion;
			nombreDeCoups := 1;

			renderMain(3, getHeight - 3, joueurJouant, allJoueur[joueurJouant].main);
			render;

			// on recupere tous les coups de l'IA
			coupsIA := coupAIPaul(g, allJoueur[joueurJouant].main);
			tmpGrille := g;
			
			IF coupsIA.pos[0].x <> -1 THEN
			BEGIN 
				FOR i := 0 TO length(coupsIA.p) - 1 DO
				BEGIN
					p := coupsIA.p[i];
					pos := coupsIA.pos[i];
					choperPos(t, pos.x, pos.y, nombreDeCoups);
					choperPion(tabPions, nombreDeCoups, p);
					IF (nCoups(g, t, tabPions, nombreDeCoups) AND (g[pos.x, pos.y].couleur = 0)) OR isFirst THEN
					BEGIN
						ajouterPion(g, p, pos.x, pos.y, intToStr(joueurJouant));
						removePionFromMain(allJoueur[joueurJouant].main, p);
						renderGame(g);
						render;
						inc(nombreDeCoups);
					END
					ELSE
					BEGIN
						writeln('IAPAUL : PION NON JOUABLE => ERREUR FATALE');
					END;
				END;
			END
			ELSE
			BEGIN
				writeln('peut rien jouer');
			END;

			allJoueur[joueurJouant].score := allJoueur[joueurJouant].score + point(g, t, nombreDeCoups);
			//renderScore(joueurJouant, allJoueur[joueurJouant].score);
			renderGame(g);
			//renderHistorique;
			render;

			lastSize := length(allJoueur[joueurJouant].main);
			FOR i := 0 TO 6 - lastSize - 1 DO
			BEGIN
				setLength(allJoueur[joueurJouant].main, length(allJoueur[joueurJouant].main) + 1);
				allJoueur[joueurJouant].main[lastSize + i] := piocher;
			END;

		END;
	UNTIL hasWon(g, allJoueur[joueurJouant]) or stop;
END.
