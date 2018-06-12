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
	bestScore, counter : INTEGER;
	bestBranche : ptrBranche;
	iter : int64;

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
			setLength(tmp^.lastPion, length(branche^.lastPion) + 1);
			tmp^.lastPos := branche^.lastPos;
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

	FUNCTION findFourPos(g: grille; x, y : INTEGER) : tabPos;
	VAR
		i : INTEGER;
		final : tabPos;
	BEGIN
		i := x;

		// vers la droite
		WHILE g[i,y].couleur <> 0 DO inc(i);

		setLength(final, 1);
		final[0].x := i;
		final[0].y := y;

		// gauche
		i := x;
		WHILE g[i,y].couleur <> 0 DO dec(i);

		setLength(final, 2);
		final[1].x := i;
		final[1].y := y;

		// haut
		i := y;
		WHILE g[x,i].couleur <> 0 DO dec(i);

		setLength(final, 3);
		final[2].x := i;
		final[2].y := y;

		i := y;
		WHILE g[x,i].couleur <> 0 DO inc(i);

		setLength(final, 4);
		final[3].x := i;
		final[3].y := y;

		findFourPos := final;
	END;

	PROCEDURE createFullTree(g : grille; arbre : ptrBranche; main : mainJoueur);
	VAR
		i, j, x, y : INTEGER;
		tmpMain : mainJoueur;
		tmpGrille, tmp2Grille : grille;
		tabCoupPos : tabPos;
		tabCoupPion : tabPion;
		tmpBranche : ptrbranche;
		allPos : tabPos;
	BEGIN
		// on pose le pion d'avant dans la grille
		// on fait tout comme si il avait ete place
		writeln('DOWN : ', arbre^.down);

		tmpGrille := g;
		ajouterPion(tmpGrille, arbre^.lastPion[arbre^.down - 1], arbre^.lastPos[arbre^.down - 1].x, arbre^.lastPos[arbre^.down - 1].y, 'T');
		tmpMain := main;

		writeln('pion : ', arbre^.lastPion[arbre^.down - 1].couleur, ' ,', arbre^.lastPion[arbre^.down - 1].forme, ' ,', arbre^.lastPos[arbre^.down - 1].x, ' ,', arbre^.lastPos[arbre^.down - 1].y);
		removePionFromMain(tmpMain, arbre^.lastPion[arbre^.down - 1]);
		write('main ', length(tmpMain), ' / ');
		FOR i := 0 TO length(tmpMain) - 1 DO write(tmpMain[i].couleur, ' ,');
		writeln;

		tabCoupPos := arbre^.lastPos;
		tabCoupPion := arbre^.lastPion;

		FOR i := 0 TO length(tmpMain) - 1 DO
		BEGIN
			allPos := findFourPos(tmpGrille, arbre^.lastPos[arbre^.down - 1].x, arbre^.lastPos[arbre^.down - 1].y);
			FOR j := 0 TO length(allPos) - 1 DO
			BEGIN
				inc(iter);

				x := allPos[j].x;
				y := allPos[j].y;

				//on ajoute le coups hypothétique voir si il marche
				setLength(tabCoupPos, length(tabCoupPos) + 1);
				setLength(tabCoupPion, length(tabCoupPion) + 1);
				tabCoupPos[length(tabCoupPos) - 1].x := x;
				tabCoupPos[length(tabCoupPos) - 1].y := y;
				tabCoupPion[length(tabCoupPion) - 1] := tmpMain[i];

				writeln('debut');
				writeln(nCoups(tmpGrille, tabCoupPos, tabCoupPion, arbre^.down + 1));
				writeln(tmpGrille[x, y].couleur = 0);
				writeln('fin');

				IF nCoups(tmpGrille, tabCoupPos, tabCoupPion, arbre^.down + 1) AND (tmpGrille[tabCoupPos[length(tabCoupPos) - 1].x, tabCoupPos[length(tabCoupPos) - 1].y].couleur = 0) AND (tmpMain[i].couleur <> 0) THEN
				BEGIN
					writeln('je suis la NCOUPS', tmpMain[i].couleur <> 0);
					tmpBranche := createBranche(arbre, tmpMain[i], x, y);
					writeln('je suis la apres');

					// coucou je suis la récursivité !
					createFullTree(tmpGrille, tmpBranche, tmpMain);

					addBranche(arbre, tmpBranche);
					writeln('----------------------------------------');
				END;

				// si le coup ne marche pas on le supprime et passe au suivant
				setLength(tabCoupPos, length(tabCoupPos) - 1);
				setLength(tabCoupPion, length(tabCoupPion) - 1);
				writeln('apres setLength', length(tabCoupPos));
			END;
		END;

		arbre^.points := point(g, arbre^.lastPos, arbre^.down);

		IF arbre^.points > bestScore THEN
		BEGIN
			bestScore := arbre^.points;
			bestBranche := arbre;
		END;
		writeln('++++++++++++++++++++++++++++');
		writeln('score : ', arbre^.points);
		writeln('++++++++++++++++++++++++++++');
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

	PROCEDURE afficherPossibilites(g :  grille; arbre : ptrBranche);
	VAR
		tmpGrille : grille;
		i : INTEGER;
	BEGIN
		IF length(arbre^.sousBranche) > 0 THEN
		BEGIN
			// on cherche le bas de la branche
			FOR i := 0 TO length(arbre^.sousBranche) - 1 DO
			BEGIN
				afficherPossibilites(g, arbre^.sousBranche[i]);
			END;
		END
		ELSE
		BEGIN
			writeln('je suis la');
			tmpGrille := g;
			FOR i := 0 TO length(arbre^.lastPos) - 1 DO
			BEGIN
				ajouterPion(tmpGrille, arbre^.lastPion[i], arbre^.lastPos[i].x, arbre^.lastPos[i].y,'T');
				writeln(arbre^.lastPion[i].couleur, ', ', arbre^.lastPion[i].forme, ', ',arbre^.lastPos[i].x, ', ', arbre^.lastPos[i].y);
			END;
			renderGame(tmpGrille);
			render;
			inc(counter);
			log('grille n ' + inttostr(counter) + ', score : ' + inttostr(arbre^.points));
		END;
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
		i, counter : INTEGER;
		p : pion;
		tmpGrille : grille;
		arbre, tmp : ptrBranche;
		tmpFinal : typeCoup;
	BEGIN
		bestScore := 0;
		counter := 0;
		bestBranche := NIL;
		tabMove := findAllPosibleMove(g, main);
		arbre := initArbre(g, main, tabMove);
		//log('tailleArbre : ' + inttostr(length(arbre^.sousBranche)));
		//afficherBrancheArbre(g, arbre);
		FOR i := 0 TO length(arbre^.sousBranche) - 1 DO
		BEGIN
			createFullTree(g, arbre^.sousBranche[i], main);
		END;
		writeln(iter);

		log('FIN createFullTree');

		writeln('FIN IA');
		// on va explorer ce que fait notre cher IA

		tmpFinal.p := bestBranche^.lastPion;
		tmpFinal.pos := bestBranche^.lastPos;
		coupAIPaul := tmpFinal;
	END;
END.
