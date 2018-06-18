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

FUNCTION coupAIPaul(g : grille; main : tabPion) : typeCoup;
FUNCTION initArbre(g : grille; main : tabPion; tabMove : tabPossibleMovePosition) : ptrBranche;
FUNCTION findAllPosibleMove(g : grille; main : tabPion) : tabPossibleMovePosition;

IMPLEMENTATION
VAR
	bestScore, counter : INTEGER;
	bestBranche : typeCoup;
	iter : int64;

	FUNCTION caseJouable(g : GRILLE; x,y : INTEGER) : BOOLEAN;
	VAR
		nbrVoisin, estDejaOccupe, nestPasSeule, etatsOK : BOOLEAN;
	BEGIN
		IF (x < 0) OR (y < 0) OR (y > length(g) - 1) OR (x > length(g) - 1) THEN
		BEGIN
			caseJouable  := FALSE;
		END
		ELSE
		BEGIN
			nbrVoisin     := NOT ((calculNombreDeVoisinLigne(g, x, y) > 5) OR (calculNombreDeVoisinColonne(g, x, y) > 5));
			//writeln('nbrVoisin', x, ',', y);
			estDejaOccupe := NOT (g[x,y].couleur <> 0);
			//writeln('deja');
			nestPasSeule  := (calculNombreDeVoisinLigne(g,x,y) + calculNombreDeVoisinColonne(g,x,y) > 0);
			//writeln('passeule');
			etatsOK       := (findEtat(g,x,y,1) = findEtat(g,x,y,3)) AND (findEtat(g,x,y,2) = findEtat(g,x,y,4));
			//writeln('etatOK');
			caseJouable  := nestPasSeule AND estDejaOccupe AND nbrVoisin AND etatsOK;
		END;
	END;

	PROCEDURE addBranche(branche, sousBranche : ptrBranche);
	BEGIN
		setLength(branche^.sousBranche, length(branche^.sousBranche) + 1);
		branche^.sousBranche[length(branche^.sousBranche) - 1] := sousBranche;
	END;
	
	FUNCTION copyMain(main : tabPion) : tabPion;
	VAR
		i : INTEGER;
		tmp : tabPion;
	BEGIN
		setLength(tmp, length(main));
		FOR i := 0 TO length(main) - 1 DO
			tmp[i] := main[i];
		copyMain := tmp;
	END;
	
	FUNCTION copyTabPos(main : tabPos) : tabPos;
	VAR
		i : INTEGER;
		tmp : tabPos;
	BEGIN
		setLength(tmp, length(main));
		FOR i := 0 TO length(main) - 1 DO
			tmp[i] := main[i];
		copyTabPos := tmp;
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
			tmp^.lastPion := copyMain(branche^.lastPion);
			setLength(tmp^.lastPion, length(branche^.lastPion) + 1);
			tmp^.lastPos := copyTabPos(branche^.lastPos);
			setLength(tmp^.lastPos, length(branche^.lastPos) + 1);
			tmp^.down := branche^.down + 1;
		END
		ELSE
		BEGIN
			tmp^.down := 1;
			setLength(tmp^.lastPion, 1);
			setLength(tmp^.lastPos, 1);
		END;

		tmp^.lastPos[tmp^.down - 1].x := x;
		tmp^.lastPos[tmp^.down - 1].y := y;
		tmp^.lastPion[tmp^.down - 1] := p;

		createBranche := tmp;
	END;

	// la branche racine sert à garder les autres branches. Elle n'est jamais utilisée autrement
	FUNCTION initArbre(g : grille; main : tabPion; tabMove : tabPossibleMovePosition) : ptrBranche;
	VAR
		i, j : INTEGER;
		racine, tmpBranche : ptrbranche;
	BEGIN
		new(racine);
		FOR i := 0 TO length(tabMove) - 1 DO
		BEGIN
			FOR j := 0 TO length(main) - 1 DO
			BEGIN
				IF placer(g, tabMove[i].x, tabMove[i].y, main[j]) OR ((length(tabMove) = 1) AND (tabMove[0].x = length(g) DIV 2)) THEN
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
	FUNCTION findAllPosibleMove(g : grille; main : tabPion) : tabPossibleMovePosition;
	VAR
		x, y : INTEGER;
		possibleMove : tabPossibleMovePosition;
	BEGIN
		setLength(possibleMove, 0);
		
		// on parcourt toute la grille pour voire où on peut mettre des pions
		FOR x := 0 TO length(g) - 1 DO
		BEGIN
			FOR y := 0 TO length(g) - 1 DO
			BEGIN
				IF caseJouable(g, x, y) THEN
				BEGIN
					setLength(possibleMove, length(possibleMove) + 1);
					possibleMove[length(possibleMove) - 1].x := x;
					possibleMove[length(possibleMove) - 1].y := y;
				END;
			END;
		END;
		
		
		
		IF length(possibleMove) < 1 THEN
		BEGIN
			setLength(possibleMove, 1);
			possibleMove[0].x := length(g) DIV 2;
			possibleMove[0].y := length(g) DIV 2;
		END;

		findAllPosibleMove := possibleMove;
	END;

	FUNCTION findFourPos(g: grille; x, y : INTEGER) : tabPos;
	VAR
		i : INTEGER;
		final : tabPos;
	BEGIN
		i := x;

		// vers la droite
		WHILE (i < length(g) - 1) AND (g[i,y].couleur <> 0)  DO inc(i);

		setLength(final, 1);
		final[0].x := i;
		final[0].y := y;

		// gauche
		i := x;
		WHILE (i > 0) AND (g[i,y].couleur <> 0) DO dec(i);

		setLength(final, 2);
		final[1].x := i;
		final[1].y := y;

		// haut
		i := y;
		WHILE (i > 0) AND (g[x,i].couleur <> 0) DO dec(i);

		setLength(final, 3);
		final[2].x := i;
		final[2].y := y;

		i := y;
		WHILE (i < length(g) - 1) AND (g[x,i].couleur <> 0) DO inc(i);

		setLength(final, 4);
		final[3].x := i;
		final[3].y := y;

		findFourPos := final;
	END;

	PROCEDURE createFullTree(g : grille; arbre : ptrBranche; main : tabPion);
	VAR
		i, j, x, y : INTEGER;
		tmpMain : tabPion;
		tmpGrille, tmp2Grille : grille;
		tabCoupPos : tabPos;
		tabCoupPion : tabPion;
		tmpBranche : ptrbranche;
		allPos : tabPos;
	BEGIN
		// on pose le pion d'avant dans la grille
		// on fait tout comme si il avait ete place
		tmpGrille := copyGrille(g);
		tmpMain := copyMain(main);
		ajouterPion(tmpGrille, arbre^.lastPion[arbre^.down - 1], arbre^.lastPos[arbre^.down - 1].x, arbre^.lastPos[arbre^.down - 1].y, 'T');

		tabCoupPos := copyTabPos(arbre^.lastPos);
		tabCoupPion := copyMain(arbre^.lastPion);

		FOR i := 0 TO length(tmpMain) - 1 DO
		BEGIN
			allPos := findFourPos(tmpGrille, arbre^.lastPos[arbre^.down - 1].x, arbre^.lastPos[arbre^.down - 1].y);
			FOR j := 0 TO length(allPos) - 1 DO
			BEGIN
				x := allPos[j].x;
				y := allPos[j].y;
				
				IF (x < 1) OR (y < 1) OR (y >= length(tmpGrille) - 2) OR (x >= length(tmpGrille) - 2)THEN
				BEGIN
					//writeln('je suis la et ca va bugger');
					redimensionnerGrille(tmpGrille);
					IF (x < 1) OR (y < 1) THEN
					BEGIN
						x := allPos[j].x + 1;
						y := allPos[j].y + 1;
					END;
				END;
				
				//on ajoute le coups hypothétique voir si il marche
				setLength(tabCoupPos, length(tabCoupPos) + 1);
				setLength(tabCoupPion, length(tabCoupPion) + 1);
				tabCoupPos[length(tabCoupPos) - 1].x := x;
				tabCoupPos[length(tabCoupPos) - 1].y := y;
				tabCoupPion[length(tabCoupPion) - 1] := tmpMain[i];

				IF nCoups(tmpGrille, tabCoupPos, tabCoupPion, arbre^.down + 1) AND (tmpGrille[x, y].couleur = 0) AND (tmpMain[i].couleur <> 0) THEN
				BEGIN
					tmpBranche := createBranche(arbre, tmpMain[i], x, y);

					// coucou je suis la récursivité !
					createFullTree(tmpGrille, tmpBranche, tmpMain);

					addBranche(arbre, tmpBranche);
				END;

				// si le coup ne marche pas on le supprime et passe au suivant
				setLength(tabCoupPos, length(tabCoupPos) - 1);
				setLength(tabCoupPion, length(tabCoupPion) - 1);
			END;
		END;

		arbre^.points := point(tmpGrille, arbre^.lastPos, arbre^.down);

		IF arbre^.points > bestScore THEN
		BEGIN
			bestScore := arbre^.points;
			setLength(bestBranche.p, length(arbre^.lastPion));
			setLength(bestBranche.pos, length(arbre^.lastPos));
			FOR i := 0 TO length(arbre^.lastPion) - 1 DO
					bestBranche.p[i] := arbre^.lastPion[i];
			FOR i := 0 TO length(arbre^.lastPos) - 1 DO
					bestBranche.pos[i] := arbre^.lastPos[i];
		END;
		
		setLength(tmpGrille, 0, 0);
	END;

	PROCEDURE clearTree(arbre : ptrBranche);
	VAR
		i : INTEGER;
	BEGIN
		IF arbre = NIL THEN
		BEGIN
			WHILE length(arbre^.sousBranche) <> 0 DO
				FOR i := 0 TO length(arbre^.sousBranche) DO
					clearTree(arbre^.sousBranche[i]);
		
			setLength(arbre^.lastPion, 0);
			setLength(arbre^.lastPos, 0);
			setLength(arbre^.sousBranche, 0);
			dispose(arbre);
		END;
	END;

	// pour faire jouer l'ia faites appelle à cette fonction. Cette unique fonction
	FUNCTION coupAIPaul(g : grille; main : tabPion) : typeCoup;
	VAR
		tabMove : tabPossibleMovePosition;
		i, counter : INTEGER;
		p : pion;
		arbre, tmp : ptrBranche;
		tmpFinal : typeCoup;
	BEGIN
		bestScore := -10;
		
		tabMove := findAllPosibleMove(g, main);
		arbre := initArbre(g, main, tabMove);
		
		//writeln('apres tabMove et arbre');
		
		FOR i := 0 TO length(arbre^.sousBranche) - 1 DO
		BEGIN
			createFullTree(g, arbre^.sousBranche[i], main);
		END;
		
		writeln(' je suis avant le clear');
		
		clearTree(arbre);
		
		//writeln('apres fullTree');
		
		IF length(bestBranche.p) <> 0 THEN
		BEGIN
			tmpFinal.p := bestBranche.p;
			tmpFinal.pos := bestBranche.pos;
			coupAIPaul := tmpFinal;
		END
		ELSE
		BEGIN
			setLength(tmpFinal.pos, 1);
			setLength(tmpFinal.p, 1);
			tmpFinal.pos[0].x := -1;
			tmpFinal.pos[0].y := -1;
			tmpFinal.p[0].couleur := -1;
			tmpFinal.p[0].forme := -1;
			
			coupAIPaul := tmpFinal;
		END;
	END;
END.
