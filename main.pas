PROGRAM main;
USES crt, sysutils, game, console, structures, legal;

VAR
	i, ii, joueurJouant, nombreDeCoups : INTEGER;
	nbrJoueurHumain, nbrJoueurMachine, nbrCouleurs, nbrFormes, nbrTuiles : INTEGER;
	allJoueur : tabJoueur;
	pos : position;
	g : grille;
	p : pion;
	stop, aFiniDeJouer, isFirst : BOOLEAN;
	t : tabPos;
	responce : CHAR;
BEGIN
	// initialisation des variables, on est jamais trop prudent avec
	// pascal <3
	nbrCouleurs      := 0;
	nbrFormes        := 0;
	nbrTuiles        := 0;
	nbrJoueurHumain  := 0;
	nbrJoueurMachine := 0;
	joueurJouant     := 0;
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
		nbrJoueurHumain  := 2;
		nbrJoueurMachine := 0;
	END;

	initConsole;

	// on creer la pioche
	initPioche(nbrCouleurs, nbrFormes, nbrTuiles);
	initJoueur(nbrJoueurHumain, nbrJoueurMachine);
	g := remplirGrille;

	renderMenuBorder;
	renderTitle('Qwirkle par Cyril et Paul :');
	render;

	// on creer les mains
	setLength(allJoueur, nbrJoueurHumain + nbrJoueurMachine);
	FOR i := 0 TO nbrJoueurHumain - 1 DO
	BEGIN
		allJoueur[i].main  := creerMain;
		allJoueur[i].genre := True;
		allJoueur[i].score := 0;
	END;

	FOR i := 0 TO nbrJoueurMachine - 1 DO
	BEGIN
		allJoueur[i + nbrJoueurHumain].main  := creerMain;
		allJoueur[i + nbrJoueurHumain].genre := False;
		allJoueur[i + nbrJoueurHumain].score := 0;
	END;

	isFirst := True;

	REPEAT
		joueurJouant := joueurJouant MOD (nbrJoueurHumain + nbrJoueurMachine);
		renderTitle('Tour du joueur ' + inttostr(joueurJouant) + '...');
		renderPopUp('C''est au joueur : ' + inttostr(joueurJouant) + ' de jouer...');
		renderGame(g);
		// on fait jouer le joueur humain / machine
		IF allJoueur[joueurJouant].genre THEN
		BEGIN
			nombreDeCoups := 1;
			aFiniDeJouer := False;
			t := initTabPos();
			REPEAT
				p := selectorMain(allJoueur[i].main, joueurJouant);
				IF NOT isFirst THEN
				BEGIN
					pos := selectorPos(g);
					pos.x := pos.x - 2;
					pos.y := pos.y - 2;
					writeln(pos.x, pos.y);
				END
				ELSE
				BEGIN
					pos.x := 12;
					pos.y := 12;
				END;
				choperPos(t, pos.x, pos.y, nombreDeCoups);
				IF nCoups(g, t, nombreDeCoups) OR isFirst THEN
				BEGIN
					ajouterPion(g, p, pos.x, pos.y, intToStr(joueurJouant));
					removePionFromPioche(allJoueur[joueurJouant].main, p);
					addToHistorique(p, pos.x, pos.y, intToStr(joueurJouant));
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
						aFiniDeJouer := True;
				END
				ELSE
				BEGIN
					renderPopUp('Pas possible de jouer la');
					aFiniDeJouer := False;
				END;
			UNTIL aFiniDeJouer;
			allJoueur[joueurJouant].score := allJoueur[joueurJouant].score + point(g, t, nombreDeCoups);
			renderScore(joueurJouant, allJoueur[joueurJouant].score);
			renderGame(g);
			renderHistorique;
			render;
			FOR i := 0 TO nombreDeCoups - 1 DO
			BEGIN
				setLength(allJoueur[joueurJouant].main, length(allJoueur[joueurJouant].main) + 1);
				allJoueur[joueurJouant].main[6 - nombreDeCoups + i] := piocher;
			END;
		END
		ELSE
		BEGIN
			// partie IA
		END;
		inc(joueurJouant);
	UNTIL hasWon or stop;

END.
