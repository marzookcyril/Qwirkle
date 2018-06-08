UNIT pAI;
INTERFACE
USES legal, console, crt, sysutils, structures, constants, game;

TYPE
	tabPossibleMovePosition = ARRAY OF position;
	ptrBranche = ^Tbranche;
	Tbranche = RECORD
		avant       : ptrBranche;
		pos         : position;
		p           : pion;
		points      : INTEGER;
		sousBranche : ARRAY OF ptrBranche;
	END;

FUNCTION coupAIPaul(g : grille; main : mainJoueur) : tabCoups;

IMPLEMENTATION

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
		log('posX : ' + inttostr(sousBranche^.pos.x));
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
		tmp^.pos.x := x;
		tmp^.pos.y := y;
		tmp^.p := p;
		tmp^.points := -1;
		setLength(tmp^.sousBranche, 0);

		createBranche := tmp;
	END;

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
					tmpBranche := createBranche(racine, main[j], tabMove[i].x, tabMove[i].y);
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
		tmpGrille : grille;
		tabCoupPos : tabPos;
		tabCoupPion : tabPion;
		tmpBranche : ptrbranche;
	BEGIN
		// on pose le pion d'avant dans la grille
		// on fait tout comme si il avait ete place
		tmpGrille := g;
		ajouterPion(tmpGrille, arbre^.p, arbre^.pos.x, arbre^.pos.y, 'AI');
		tmpMain := main;
		removePionFromMain(tmpMain, p);

		// les fonctions de cyril...
		tabCoupPos := creerTabPosPrec(arbre);
		tabCoupPion := creerTabPionPrec(arbre);

		// pour tous les pions dans la sousBranche
		FOR i := 0 TO length(arbre^.sousBranche) - 1 DO
		BEGIN
			setLength(tabCoupPos, length(tabCoupPos) + 1);
			tabCoupPos[length(tabCoupPos) - 1].x := arbre^.sousBranche[i]^.pox.x + x;
			tabCoupPos[length(tabCoupPos) - 1].y := arbre^.sousBranche[i]^.pox.y + y;
			setLength(tabCoupPion, length(tabCoupPion) + 1);
			tabCoupPion[length(tabCoupPos) - 1] := tmpMain[j];
			// pour tous les pions dans la main
			FOR j := 0 TO length(tmpMain) - 1 DO
			BEGIN
				FOR x := -1 TO 1 DO
				BEGIN
					FOR y := -1 TO 1 DO
					BEGIN


						// si ce coup est jouable, on l'ajoute à la branche
						IF nCoups(tmpGrille, tabCoupPos, tabCoupPion, length(tabCoupPion)) THEN
						BEGIN
							tmpBranche := createBranche(arbre, tmpMain[j], arbre^.pox.x + x, arbre^.pox.y + y);
							addBranche(arbre^.sousBranche[i], tmpBranche);
						END;
					END;
				END;
			END;
		END;
	END;

	FUNCTION creerTabPosPrec(arbre : ptrBranche) : tabPos;
	VAR
		tmp : ptrBranche;
		tmpCoup : position;
		tabDesCoups : tabPos;
	BEGIN
		tmp := arbre;
		setLength(tabDesCoups, 0);

		// on recupere tous les coups jouables
		WHILE tmp^.avant <> NIL DO
		BEGIN
			setLength(tabDesCoups, length(tabDesCoups) + 1);
			tabDesCoups[length(tabDesCoups) - 1].pos := tmp^.pos;
			tmp := tmp^.avant;
		END;

		// on inverse le tab car on recupere du dernier au premier coup...
		FOR i := 0 TO length(tabDesCoups) - 1 DO
		BEGIN
			tmpCoup := tabDesCoups[length(tabDesCoups) - i];
			tabDesCoups[length(tabDesCoups) - i] := tabDesCoups[i];
			tabDesCoups[i] := tmpCoup;
		END;

		creerTabCoupsPrec := tabDesCoups;
	END;

	FUNCTION creerTabPionPrec(arbre : ptrBranche) : tabPion;
	VAR
		tmp : ptrBranche;
		tmpCoup : pion;
		tabDesCoups : tabPion;
	BEGIN
		tmp := arbre;
		setLength(tabDesCoups, 0);

		// on recupere tous les coups jouables
		WHILE tmp^.avant <> NIL DO
		BEGIN
			setLength(tabDesCoups, length(tabDesCoups) + 1);
			tabDesCoups[length(tabDesCoups) - 1].p := tmp^.p;
			tmp := tmp^.avant;
		END;

		// on inverse le tab car on recupere du dernier au premier coup...
		FOR i := 0 TO length(tabDesCoups) - 1 DO
		BEGIN
			tmpCoup := tabDesCoups[length(tabDesCoups) - i];
			tabDesCoups[length(tabDesCoups) - i] := tabDesCoups[i];
			tabDesCoups[i] := tmpCoup;
		END;

		creerTabCoupsPrec := tabDesCoups;
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
			ajouterPion(tmpGrille,p,tabMove[i].x,tabMove[i].y,'AI');
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

		log('sB[0] : ' + inttostr(arbre^.sousBranche[1]^.pos.x));
		log('taille sousBranche ' + inttostr(length(arbre^.sousBranche)));

		FOR i := 0 TO length(arbre^.sousBranche) - 1 DO
		BEGIN
			ajouterPion(tmpGrille,arbre^.sousBranche[i]^.p, arbre^.sousBranche[i]^.pos.x, arbre^.sousBranche[i]^.pos.y,'AI');
			renderGame(tmpGrille);
			render;
			log('pos : ' + inttostr(arbre^.sousBranche[i]^.pos.x) + ',' + inttostr(arbre^.sousBranche[i]^.pos.y) + ',' + intToStr(i));
		END;

		renderGame(g);
		render;
	END;

	// pour faire jouer l'ia faites appelle à cette fonction. Cette unique fonction
	FUNCTION coupAIPaul(g : grille; main : mainJoueur) : tabCoups;
	VAR
		tabMove : tabPossibleMovePosition;
		i : INTEGER;
		p : pion;
		tmpGrille : grille;
		arbre : ptrBranche;
	BEGIN
		tabMove := findAllPosibleMove(g, main);
		afficherCoupsJouables(g, tabMove);
		arbre := initArbre(g, main, tabMove);
		log('tailleArbre : ' + inttostr(length(arbre^.sousBranche)));
		afficherBrancheArbre(g, arbre);
	END;
END.
