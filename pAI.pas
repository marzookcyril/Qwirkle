UNIT pAI;
INTERFACE
USES legal, console, crt, sysutils, structures, constants, game;

TYPE
	tabPossibleMovePosition = ARRAY OF position;
	ptrBranche = ^Tbranche;
	Tbranche = RECORD
		avant       : ptrBranche;
		points      : INTEGER;
		sousBranche : ARRAY OF ptrBranche;
		lastPion    : tabPion;
		lastPos     : tabPos;
		down        : INTEGER;
	END;

FUNCTION coupAIPaul(g : grille; main : mainJoueur) : typeCoup;

IMPLEMENTATION
VAR
	bestScore : INTEGER;
	bestBranche : ptrBranche;

	FUNCTION caseJouable(g : GRILLE; x,y : INTEGER) : BOOLEAN;
	VAR
		nbrVoisin, estDejaOccupe, nestPasSeule, etatsOK : BOOLEAN;
	BEGIN
		nbrVoisin     := NOT ((calculNombreDeVoisinLigne(g, x, y) > 5) OR (calculNombreDeVoisinColonne(g, x, y) > 5));
		estDejaOccupe := NOT (g[x,y].couleur <> 0);
		nestPasSeule  := (calculNombreDeVoisinLigne(g,x,y) + calculNombreDeVoisinColonne(g,x,y) > 0);
		etatsOK       := (findEtat(g,x,y,1) = findEtat(g,x,y,3)) AND (findEtat(g,x,y,2) = findEtat(g,x,y,4));

		caseJouable  := nestPasSeule AND estDejaOccupe AND nbrVoisin AND etatsOK;
	END;

	PROCEDURE addBranche(branche, sousBranche : ptrBranche);
	BEGIN
		setLength(branche^.sousBranche, length(branche^.sousBranche) + 1);
		branche^.sousBranche[length(branche^.sousBranche) - 1] := 	sousBranche;
	END;

	FUNCTION createBranche(branche : ptrBranche; p : pion; x,y : INTEGER) : ptrBranche;
	VAR
		tmp : ptrBranche;
	BEGIN
		new(tmp);
		// on creer la sous branche
		tmp^.avant := branche;
		tmp^.points := -1;

		setLength(tmp^.sousBranche, 0);

		IF branche <> NIL THEN
		BEGIN
			tmp^.lastPion := branche^.lastPion;
			setLength(tmp^.lastPion, length(tmp^.lastPion) + 1);
			tmp^.lastPos := branche^.lastPos;
			setLength(tmp^.lastPos, length(tmp^.lastPos) + 1);
			tmp^.down := branche^.down + 1;
		END
		ELSE
		BEGIN
			tmp^.down := 0;
			setLength(tmp^.lastPion, 1);
			setLength(tmp^.lastPos, 1);
		END;

		tmp^.lastPos[tmp^.down].x := x;
		tmp^.lastPos[tmp^.down].y := y;
		tmp^.lastPion[tmp^.down] := p;

		createBranche := tmp;
	END;

	// la branche racine sert à garder les autres branches. Elle n'est jamais utilisée autrement
	FUNCTION initArbre(g : grille; main : mainJoueur; tabMove : tabPossibleMovePosition) : ptrBranche;
	VAR
		i, j : INTEGER;
		racine, tmpBranche : ptrbranche;
	BEGIN
		new(racine);
		FOR i := 0 TO length(tabMove) - 1 DO
		BEGIN
			FOR j := 0 TO length(main) - 1 DO
			BEGIN
				IF placer(g, tabMove[i].x, tabMove[i].y, main[j]) THEN
				BEGIN
					tmpBranche := createBranche(NIL, main[j], tabMove[i].x, tabMove[i].y);
					addBranche(racine, tmpBranche);
				END;
			END;
		END;

		initArbre := racine;
	END;

	// recupere toutes les positions jouables sur la grille et leur affecte un attribut
	// etat qui dicte ce que l'on peut jouer à l'endroit étudié
	FUNCTION findAllPosibleMove(g : grille; main : mainJoueur) : tabPossibleMovePosition;
	VAR
		x, y : INTEGER;
		possibleMove : tabPossibleMovePosition;
	BEGIN
		setLength(possibleMove, 0);

		// on parcourt toute la grille pour voire où on peut mettre des pions
		FOR x := 1 TO TAILLE_GRILLE - 2 DO
		BEGIN
			FOR y := 1 TO TAILLE_GRILLE - 2 DO
			BEGIN
				IF caseJouable(g,x,y) THEN
				BEGIN
					setLength(possibleMove, length(possibleMove) + 1);
					possibleMove[length(possibleMove) - 1].x := x;
					possibleMove[length(possibleMove) - 1].y := y;
				END;
			END;
		END;

		findAllPosibleMove := possibleMove;
	END;

	PROCEDURE createFullTree(g : grille; arbre : ptrBranche; main : mainJoueur);
	VAR
		i, j, x, y : INTEGER;
		tmpMain : mainJoueur;
		tmpGrille, tmp2Grille : grille;
		tabCoupPos : tabPos;
		tabCoupPion : tabPion;
		tmpBranche : ptrbranche;
	BEGIN
		// on pose le pion d'avant dans la grille
		// on fait tout comme si il avait ete place
		tmpGrille := g;
		ajouterPion(tmpGrille, arbre^.lastPion[arbre^.down], arbre^.lastPos[arbre^.down].x, arbre^.lastPos[arbre^.down].y, 'T');
		tmpMain := main;
		removePionFromMain(tmpMain, arbre^.lastPion[arbre^.down]);

		FOR i := 0 TO length(tmpMain) - 1 DO
		BEGIN
			FOR x := -1 TO 1 DO
			BEGIN
				FOR y := -1 TO 1 DO
				BEGIN
					//on ajoute le coups hypothétique voir si il marche
					setLength(arbre^.lastPos, length(arbre^.lastPos) + 1);
					setLength(arbre^.lastPion, length(arbre^.lastPion) + 1);
					arbre^.lastPos[arbre^.down + 1].x := arbre^.lastPos[arbre^.down].x + x;
					arbre^.lastPos[arbre^.down + 1].y := arbre^.lastPos[arbre^.down].y + y;
					arbre^.lastPion[arbre^.down + 1] := tmpMain[i];

					IF nCoups(tmpGrille, arbre^.lastPos, arbre^.lastPion, arbre^.down + 1) AND (g[arbre^.lastPos[arbre^.down + 1].x, arbre^.lastPos[arbre^.down + 1].y].couleur = 0) THEN
					BEGIN
						tmpBranche := createBranche(arbre, tmpMain[j], arbre^.lastPos[arbre^.down + 1].x, arbre^.lastPos[arbre^.down + 1].y);

						// coucou je suis la récursivité !
						createFullTree(tmpGrille, tmpBranche, tmpMain);

						addBranche(arbre, tmpBranche);
					END;

					setLength(arbre^.lastPos, length(arbre^.lastPos) - 1);
					setLength(arbre^.lastPion, length(arbre^.lastPion) - 1);
				END;
			END;
		END;
		// on a pas cree de sous branche, on va donc finir et remonter dans l'arbre
		IF length(arbre^.sousBranche) < 1 THEN
		BEGIN
			arbre^.points := point(g, arbre^.lastPos, arbre^.down);
			IF arbre^.points > bestScore THEN
			BEGIN
				bestBranche := arbre;
				bestScore := arbre^.points;
				ajouterPion(tmpGrille, arbre^.lastPion[arbre^.down], arbre^.lastPos[arbre^.down].x, arbre^.lastPos[arbre^.down].y, 'T');
				renderGame(tmpGrille);
				render;
				log('tour');
			END;
		END;
	END;

	PROCEDURE afficherCoupsJouables(g : grille; tabMove : tabPossibleMovePosition);
	VAR
		i : INTEGER;
		p : pion;
		tmpGrille : grille;
	BEGIN
		tmpGrille := g;
		p.couleur := COULEUR_ROUGE;
		p.forme := FORME_NULL;

		FOR i := 0 TO length(tabMove) - 1 DO
		BEGIN
			ajouterPion(tmpGrille,p,tabMove[i].x,tabMove[i].y,'T');
			renderGame(tmpGrille);
			render;
		END;

		readln;
		renderGame(g);
		render;
	END;

	PROCEDURE afficherBrancheArbre(g : grille; arbre : ptrBranche);
	VAR
		i : INTEGER;
		p : pion;
		tmpGrille : grille;
	BEGIN
		tmpGrille := g;
		p.couleur := COULEUR_ROUGE;
		p.forme := FORME_NULL;

		FOR i := 0 TO length(arbre^.sousBranche) - 1 DO
		BEGIN
			ajouterPion(tmpGrille,arbre^.sousBranche[i]^.lastPion[arbre^.down], arbre^.sousBranche[i]^.lastPos[arbre^.down].x, arbre^.sousBranche[i]^.lastPos[arbre^.down].y,'T');
			renderGame(tmpGrille);
			render;
		END;

		renderGame(g);
		render;
	END;

	// pour faire jouer l'ia faites appelle à cette fonction. Cette unique fonction
	FUNCTION coupAIPaul(g : grille; main : mainJoueur) : typeCoup;
	VAR
		tabMove : tabPossibleMovePosition;
		i : INTEGER;
		p : pion;
		tmpGrille : grille;
		arbre : ptrBranche;
		tmpFinal : typeCoup;
	BEGIN
		bestScore := 0;
		bestBranche := NIL;
		tabMove := findAllPosibleMove(g, main);
		afficherCoupsJouables(g, tabMove);
		arbre := initArbre(g, main, tabMove);
		//log('tailleArbre : ' + inttostr(length(arbre^.sousBranche)));
		//afficherBrancheArbre(g, arbre);
		createFullTree(g, arbre^.sousBranche[0], main);

		tmpFinal.p := bestBranche^.lastPion;
		tmpFinal.pos := bestBranche^.lastPos;
		coupAIPaul := tmpFinal;
	END;
END.
