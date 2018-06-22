UNIT legal;
INTERFACE
USES constants, sysutils, Math, crt, structures, game;

FUNCTION calculNombreDeVoisin(g : grille; x, y : INTEGER; dirInt : INTEGER) : INTEGER;
FUNCTION calculNombreDeVoisinColonne(g : grille; x,y : INTEGER) : INTEGER;
FUNCTION calculNombreDeVoisinLigne(g : grille; x,y : INTEGER) : INTEGER;
FUNCTION verifNombreVoisin(g : grille; x, y: INTEGER) : BOOLEAN;
FUNCTION findEtat(g : grille; x,y, dirInt : INTEGER) : STRING;
FUNCTION concordance(g : grille; x, y : INTEGER) : BOOLEAN;
FUNCTION concordanceGenerale(g: grille ; x,y : INTEGER; p : pion): BOOLEAN;
FUNCTION duplicationPion(g : grille; x,y  : INTEGER; p : pion) : BOOLEAN;
FUNCTION placer(g: grille; x, y : INTEGER; p : pion): BOOLEAN;
FUNCTION plusieursCoups(g: grille; x1,y1,x2,y2,x3,y3 : INTEGER; p1,p2 : pion) : BOOLEAN;
FUNCTION nCoups(g: grille; t : tabPos; p : tabPion; num : INTEGER) : BOOLEAN;
FUNCTION initTabPos(): tabPos;
FUNCTION initTabPion(): tabPion;
FUNCTION point(g : grille; t : tabPos ; num : INTEGER): INTEGER;
FUNCTION continu(g : grille; x1,y1,x2,y2,x3,y3 : INTEGER): BOOLEAN;
PROCEDURE choperPos(VAR t : tabPos ; x,y, num : INTEGER);
PROCEDURE choperPion(VAR t : tabPion ;num : INTEGER; p : pion);
PROCEDURE initLegal(qwirkle : INTEGER);

IMPLEMENTATION
VAR
	qwirkleSize : INTEGER;

	PROCEDURE initLegal(qwirkle : INTEGER);
	BEGIN
		qwirkleSize := qwirkle;
	END;

	// dir :    2
	//        1   3
	//          4
	FUNCTION dirValue(dir : INTEGER) : position; // on renvoie une position en fonction de la direction choisie
	VAR
		tmp : position;
	BEGIN
		CASE dir OF
			1 : BEGIN
				tmp.x := -1;
				tmp.y := 0;
			END;
			2 : BEGIN
				tmp.x := 0;
				tmp.y := -1;
			END;
			3 : BEGIN
				tmp.x := 1;
				tmp.y := 0;
			END;
			4 : BEGIN
				tmp.x := 0;
				tmp.y := 1;
			END;
			0 : BEGIN
				tmp.x := 0;
				tmp.y := 1;
			END;
		END;
		dirValue := tmp;
	END;

	FUNCTION calculNombreDeVoisin(g : grille; x, y: INTEGER; dirInt : INTEGER) : INTEGER; // On calcule de nombre de voisin dans toutes les directions
	VAR
		i : INTEGER;
		dir : position;
	BEGIN
		i := 0;
		dir := dirValue(dirInt);
		WHILE ((x + (i+1) * dir.x) > 0) AND (x + (i+1) * dir.x < length(g) - 1) AND (y + (i+1) * dir.y > 0) AND (y + (i+1) * dir.y < length(g) - 1) AND (g[x + (i+1) * dir.x, y + (i+1) * dir.y].forme <> FORME_NULL) DO
			inc(i);
		calculNombreDeVoisin := i;
	END;

	FUNCTION verifNombreVoisin(g : grille; x, y: INTEGER) : BOOLEAN; // on verifie ici que le nombre de voisins en ligne et colonne et inferieur a un Qwirkle
	VAR
		verif : BOOLEAN;
	BEGIN
		verif := TRUE;
		IF NOT (calculNombreDeVoisin(g,x,y,1) + (calculNombreDeVoisin(g,x,y,3)) <= qwirkleSize) THEN
			verif := FALSE;
		IF NOT (calculNombreDeVoisin(g,x,y,2) + (calculNombreDeVoisin(g,x,y,4)) <= qwirkleSize) THEN
			verif := FALSE;
		verifNombreVoisin := verif;
	END;

	// CODES :
	// 000 => free
	// 404 => error
	FUNCTION findEtat(g : grille; x,y, dirInt : INTEGER) : STRING; // on cherche ici a determiner l'etat d'une direction 
	VAR															  // c est a dire determiner la caracteristique forme ou couleur 
		dir, dirBis : position;                                   // qui lie les voisins 
		nbrVoisin, nbrVoisinPeu : INTEGER;
	BEGIN
		dir := dirValue(dirInt);
		nbrVoisin := calculNombreDeVoisin(g, x, y, dirInt);
		IF nbrVoisin > 1 THEN
		BEGIN
			IF g[x + dir.x, y + dir.y].forme = g[x + 2 * dir.x, y + 2 * dir.y].forme THEN   // on renvoie la forme exacte dans la direction 
			BEGIN
				findEtat :=  'F' + inttostr(g[x + dir.x, y + dir.y].forme) + '0';
			END
			ELSE
			BEGIN
				IF g[x + dir.x, y + dir.y].couleur = g[x + 2 * dir.x, y + 2 * dir.y].couleur THEN // on renvoie la couleur exacte dans la direction 
					findEtat :=  'C' + inttostr(g[x + dir.x, y + dir.y].couleur) + '0'
				ELSE
					findEtat := '404';
			END;
		END
		ELSE
		BEGIN
			IF nbrVoisin = 0 THEN
			BEGIN
				nbrVoisinPeu := calculNombreDeVoisin(g, x, y, (dirInt + 2) MOD 4);
				dir := dirValue((dirInt + 2) MOD 4);
				// le voisin opposé est seul on renvoie 000 pour dire que tout type de pions peut etre placé
				IF (x + dir.x < 0) OR (x + dir.x > length(g) - 1) OR (y + dir.y < 0) OR (y + dir.y > length(g) - 1) THEN 
				BEGIN
					findEtat := '000';
				END
				ELSE
				BEGIN
					IF nbrVoisinPeu = 0 THEN
						findEtat := '000';
					IF nbrVoisinPeu = 1 THEN
						findEtat := '0' + inttostr(g[x + dir.x, y + dir.y].forme) + inttostr(g[x + dir.x, y + dir.y].couleur);
					IF nbrVoisinPeu > 1 THEN
					BEGIN
						IF g[x + dir.x, y + dir.y].forme = g[x + 2 * dir.x, y + 2 * dir.y].forme THEN
							findEtat :=  'F' + inttostr(g[x + dir.x, y + dir.y].forme) + '0';
						IF g[x + dir.x, y + dir.y].couleur = g[x + 2 * dir.x, y + 2 * dir.y].couleur THEN
							findEtat :=  'C' + inttostr(g[x + dir.x, y + dir.y].couleur) + '0';
					END;
				END;
			END;

			IF nbrVoisin = 1 THEN // si il ya un seul voisin on renvoie le type exacte du pions en question
			BEGIN
				dirBis := dirValue((dirInt + 2) MOD 4);
				IF (x + dirBis.x < 0) OR (x + dirBis.x > length(g) - 1) OR (y + dirBis.y < 0) OR (y + dirBis.y > length(g) - 1) THEN
				BEGIN
					findEtat := '0' + inttostr(g[x + dir.x, y + dir.y].forme) + inttostr(g[x + dir.x, y + dir.y].couleur);
				END
				ELSE
				BEGIN
					IF g[x + dirBis.x, y + dirBis.y].forme <> 0 THEN
					BEGIN
						IF g[x + dir.x, y + dir.y].forme = g[x + dirBis.x, y + dirBis.y].forme THEN
						BEGIN
							findEtat :=  'F' + inttostr(g[x + dir.x, y + dir.y].forme) + '0';
						END
						ELSE
						BEGIN
							IF g[x + dir.x, y + dir.y].couleur = g[x + dirBis.x, y + dirBis.y].couleur THEN
							BEGIN
								findEtat :=  'C' + inttostr(g[x + dir.x, y + dir.y].couleur) + '0';
							END
							ELSE
								findEtat := '404';
						END;
					END
					ELSE
						findEtat := '0' + inttostr(g[x + dir.x, y + dir.y].forme) + inttostr(g[x + dir.x, y + dir.y].couleur);
				END;
			END;
		END;
	END;

	// Dans cette fonction on faitr concorder une ligne entiere et une colonne 
	FUNCTION sousConcordance(g : grille; x, y, dir : INTEGER) : BOOLEAN;
	VAR
		etat1, etat2 : STRING;
	BEGIN
		etat1 := findEtat(g, x, y, dir + 1);
		etat2 := findEtat(g, x, y, dir + 3);

		IF (etat1 = etat2) THEN
			sousConcordance := TRUE
		ELSE
			sousConcordance := FALSE;
	END;

	// on fait concorder les lignes avec les colonnes pour savoir quel sont les caracteristiques du pion qui peut etre place 
	FUNCTION concordance(g : grille; x, y : INTEGER) : BOOLEAN;
	BEGIN
		concordance := sousConcordance(g, x, y, 1) AND sousConcordance(g, x, y, 0);
	END;

	// on utilise une fonction injective pour pouvoir verifier si un pion est dupliquer pluq rapidement en ne comparemet que deux entiers
	FUNCTION injection(x, y : INTEGER) :  INTEGER;
	BEGIN
		injection := ((x + y) * (x + y + 1)) DIV 2 + y;
	END;

	// 1 en ligne / 2 en colonne
	// on verifie que l'on ne relie pas une ligne ou colonne contenant deux fois le meme pion 
	// et que le pion que lon place n'est pas deja dans la ligne ou colonne 
	FUNCTION duplicationPion(g : grille; x,y: INTEGER; p : pion) : BOOLEAN;
	VAR
		
		tmp : ARRAY [0..500] OF INTEGER;
		erreur : boolean;
		i, ii : INTEGER;
		tmpGrille : grille;
	BEGIN
		tmpGrille := copyGrille(g);
		tmpGrille[x,y] := p;
		erreur := FALSE;

		FOR i := 0 TO 499 DO
			tmp[i] := 0;

		i := x - calculNombreDeVoisin(tmpGrille, x, y, 1);
		WHILE NOT erreur AND (i <= x + calculNombreDeVoisin(tmpGrille, x, y, 3)) DO
			IF tmp[injection(tmpGrille[i, y].forme, tmpGrille[i, y].couleur)] <> 0 THEN
			BEGIN
				erreur := TRUE;
			END
			ELSE
			BEGIN
				tmp[injection(tmpGrille[i, y].forme, tmpGrille[i, y].couleur)] := 1;
				inc(i);
			END;

		FOR i := 0 TO 499 DO
			tmp[i] := 0;

		i := y - calculNombreDeVoisin(tmpGrille, x, y, 2);
		WHILE NOT erreur AND (i <= y + calculNombreDeVoisin(tmpGrille, x, y, 4)) DO
			IF tmp[injection(tmpGrille[x, i].forme, tmpGrille[x, i].couleur)] <> 0 THEN
			BEGIN
				erreur := TRUE;
			END
			ELSE
			BEGIN
				tmp[injection(tmpGrille[x, i].forme, tmpGrille[x, i].couleur)] := 1;
				inc(i);
			END;


		duplicationPion := NOT erreur;
		setLength(tmpGrille, 0, 0);
	END;

	FUNCTION placer(g: grille; x, y : INTEGER; p : pion): BOOLEAN;
	BEGIN
	IF (concordanceGenerale(g,x,y,p) AND duplicationPion(g,x,y,p)) THEN
		BEGIN
			placer := TRUE;
		END
		ELSE
			placer := FALSE;
	END;
	
	// on utilise cette fonction placer plusieurs pions pouir eviter de pouvoir les places sur la meme ligne ou colonne sans discontinuité
	FUNCTION continu(g : grille; x1,y1,x2,y2,x3,y3 : INTEGER): BOOLEAN;
	VAR
		cont: BOOLEAN;
		i : INTEGER;
	BEGIN
		cont := FALSE;
		IF (x1 = x2) THEN
		BEGIN
			cont := TRUE;
			FOR i := min(y1, y2) TO max(y1, y2) - 1 DO
			BEGIN
				IF (g[x1, i].couleur = 0) AND (i <> y2) THEN
				BEGIN
					cont := FALSE
				END;
			END;
		END;
		
		IF (y1 = y2) THEN
		BEGIN
			cont := TRUE;
			FOR i := min(x1, x2) TO max(x1, x2) DO
			BEGIN
				IF (g[i, y1].couleur = 0) AND (i <> x2) THEN
				BEGIN
					cont := FALSE
				END;
			END;
		END;
		continu := cont;
	END;

	// on verifie ici que le nieme pion que l'on place est bioen sur la meme ligne/colonne 
	// que ceux placer precedemment et qu'il n'est pas placer en discontinuité
	FUNCTION plusieursCoups(g: grille; x1,y1,x2,y2,x3,y3 : INTEGER; p1,p2 : pion) : BOOLEAN;
	VAR
		bool : BOOLEAN;
	BEGIN
		bool := FALSE;

		IF (((x1 = x2) XOR (y1 = y2)) AND placer(g,x2,y2,p2) AND continu(g,x1,y1,x2,y2,x3,y3)) THEN
		BEGIN
			bool:= TRUE;
			
		END;
		
		plusieursCoups:= bool;
	END;

	// en fonction du nombre de pion que l'on place on verifie ligne colonne etat et continuité
	FUNCTION nCoups(g: grille; t : tabPos; p : tabPion; num : INTEGER) : BOOLEAN;
	BEGIN
		CASE num OF
			1 :
			BEGIN
				IF placer(g, t[0].x, t[0].y, p[0]) THEN
				BEGIN
					nCoups := TRUE;
				END
				ELSE
					nCoups := FALSE;
			END;
			2 :
			BEGIN
				IF plusieursCoups(g, t[0].x, t[0].y, t[1].x, t[1].y, t[0].x, t[0].y, p[0], p[1]) THEN
				BEGIN
					nCoups := TRUE;
				END
				ELSE
					nCoups := FALSE;
			END
			ELSE
			BEGIN
				IF (num > 2) THEN
				BEGIN
					IF plusieursCoups(g, t[0].x,t[0].y,t[num - 1].x,t[num - 1].y,t[num - 2].x,t[num - 2].y,  p[0], p[num - 1]) AND plusieursCoups(g, t[1].x,t[1].y,t[num - 1].x,t[num - 1].y,t[num - 2].x,t[num - 2].y, p[1],p[num - 1]) THEN
					BEGIN
						nCoups := TRUE;
					END
					ELSE
						nCoups := FALSE;
				END;
			END;
		END;
	END;

	// on initie un tableau a chaque tour qui permet de stocker lespositions des pions que l'on a placé
	FUNCTION initTabPos(): tabPos;
	VAR i : INTEGER;
		t : tabPos;
	BEGIN
		setLength(t, 5);
		FOR i := 0 TO 5 Do
		BEGIN
			t[i].x := -1;
			t[i].y := -1;
		END;
		initTabPos := t;
	END;
	
	// on initie un tableau a chaque tour qui permet de stocker les pions que l'on a placé
	FUNCTION initTabPion(): tabPion;
	VAR i : INTEGER;
		t : tabPion;
	BEGIN
		setLength(t, 5);
		FOR i := 0 TO 5 Do
		BEGIN
			t[i].couleur := 0;
			t[i].forme := 0;
		END;
		initTabPion := t;
	END;

	// on prend les positions des pions placer en un tour pour faire les test pour les pions d'apres 
	PROCEDURE choperPos(VAR t : tabPos ; x,y, num : INTEGER);
	BEGIN
		t[num-1].x  := x;
		t[num-1].y  := y;
	END;

	PROCEDURE choperPion(VAR t : tabPion ;num : INTEGER; p : pion);
	BEGIN
		t[num-1] := p;
	END;

	FUNCTION calculNombreDeVoisinLigne(g : grille; x,y : INTEGER) : INTEGER;
	BEGIN
		calculNombreDeVoisinLigne := calculNombreDeVoisin(g, x, y, 1)+ calculNombreDeVoisin(g, x, y, 3);
	END;

	FUNCTION calculNombreDeVoisinColonne(g : grille; x,y : INTEGER) : INTEGER;
	BEGIN
		calculNombreDeVoisinColonne := calculNombreDeVoisin(g, x, y, 2) + calculNombreDeVoisin(g, x, y, 4);
	END;

	// on verifie si on peut placer un pion si il verifie les concordance de chaque direction
	FUNCTION concordanceGenerale(g: grille ; x,y : INTEGER; p : pion): BOOLEAN;
	VAR
		i , j: INTEGER;
		etat1 : STRING;
	BEGIN
		i := 0;
		FOR j := 1 TO 4 DO
		BEGIN
			etat1 := findEtat(g, x, y, j);
			IF ( etat1[1] = '0' ) THEN
			BEGIN
				IF (inttostr(p.couleur) = etat1[3]) OR (inttostr(p.forme) =  etat1[2]) THEN
				BEGIN
					inc(i);
				END;
			END;
			IF ( etat1[1] = 'F') THEN
			BEGIN
				IF inttostr(p.forme) = etat1[2] THEN
				BEGIN
					inc(i);
				END;
			END;
			IF ( etat1[1] = 'C') THEN
			BEGIN
				IF inttostr(p.couleur) = etat1[2] THEN
				BEGIN
					inc(i);
				END;
			END;
			IF (etat1 = '000') AND (calculNombreDeVoisinLigne(g, x, y) + calculNombreDeVoisinColonne(g, x, y) > 0) THEN
			BEGIN
				inc(i);
			END;
		END;
		IF i = 4 THEN
			concordanceGenerale := TRUE
		ELSE
			concordanceGenerale := FALSE;
	END;


	// on calcule le nombre de point en fonction du nombre de pions que l'on a placé dans notre tour
	// sans oublier le bonus lorque l'on réalise un qwirkle 
	FUNCTION point(g : grille; t : tabPos ; num : INTEGER): INTEGER;
	VAR
		i ,points : INTEGER;
	BEGIN
		points := 0;
		IF num = 1 THEN
		BEGIN
			IF (calculNombreDeVoisinLigne(g, t[0].x, t[0].y) < qwirkleSize) AND (calculNombreDeVoisinLigne(g, t[0].x, t[0].y) > 0) THEN
				points := points + calculNombreDeVoisinLigne(g, t[0].x, t[0].y) + 1;
			IF (calculNombreDeVoisinLigne(g, t[0].x, t[0].y) = qwirkleSize) THEN
				points := points + (qwirkleSize + 1) * 2;
			IF (calculNombreDeVoisinColonne(g, t[0].x, t[0].y) < qwirkleSize) AND (calculNombreDeVoisinColonne(g, t[0].x, t[0].y) > 0) THEN
				points := points + calculNombreDeVoisinColonne(g, t[0].x, t[0].y) + 1;
			IF (calculNombreDeVoisinColonne(g, t[0].x, t[0].y) = qwirkleSize) THEN
				points := points + (qwirkleSize + 1) * 2;
		END
		ELSE
		BEGIN
			// en colonne
			IF t[0].x = t[1].x THEN
			BEGIN
				FOR i := 0 TO num - 1 DO
				BEGIN
					IF (calculNombreDeVoisinLigne(g, t[i].x, t[i].y) < qwirkleSize) AND (calculNombreDeVoisinLigne(g, t[i].x, t[i].y) > 0) THEN
						points := points + calculNombreDeVoisinLigne(g, t[i].x, t[i].y) + 1;
					IF (calculNombreDeVoisinLigne(g, t[i].x, t[i].y) = qwirkleSize) THEN
						points := points + (qwirkleSize + 1) * 2;
				END;
				IF (calculNombreDeVoisinColonne(g, t[0].x, t[0].y) < qwirkleSize) AND (calculNombreDeVoisinColonne(g, t[0].x, t[0].y) > 0) THEN
					points := points + calculNombreDeVoisinColonne(g, t[0].x, t[0].y) + 1;
				IF (calculNombreDeVoisinColonne(g, t[0].x, t[0].y) = qwirkleSize) THEN
					points := points + (qwirkleSize + 1) * 2;
			END;
			IF t[0].y = t[1].y THEN
			BEGIN
				FOR i := 0 TO num - 1 DO
				BEGIN
					IF (calculNombreDeVoisinColonne(g, t[i].x, t[i].y) < qwirkleSize) AND (calculNombreDeVoisinColonne(g, t[i].x, t[i].y) > 0) THEN
						points := points + calculNombreDeVoisinColonne(g, t[i].x, t[i].y) + 1;
					IF (calculNombreDeVoisinColonne(g, t[i].x, t[i].y) = qwirkleSize) THEN
						points := points + (qwirkleSize + 1) * 2;
				END;
				IF (calculNombreDeVoisinLigne(g, t[0].x, t[0].y) < qwirkleSize) AND (calculNombreDeVoisinLigne(g, t[0].x, t[0].y) > 0) THEN
					points := points + calculNombreDeVoisinLigne(g, t[0].x, t[0].y) + 1;
				IF (calculNombreDeVoisinLigne(g, t[0].x, t[0].y) = qwirkleSize) THEN
					points := points +  (qwirkleSize + 1) * 2;
			END;
		END;
		point := points;
	END;
END.
