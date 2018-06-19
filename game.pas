UNIT game;
INTERFACE
USES crt, sysutils, constants, structures;

PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
FUNCTION remplirGrille(): grille;
PROCEDURE initPioche(nbrCouleurs, nbrFormes, nbrTuiles : INTEGER);
PROCEDURE shufflePioche;
FUNCTION creerMain: tabPion;
PROCEDURE removePionFromMain(VAR main : tabPion; p : pion);
PROCEDURE echangerPion(VAR main : tabPion; p : pion);
PROCEDURE initJoueur(nbrJoueurHumain, nbrJoueurMachine : INTEGER);
FUNCTION piocher : pion;
FUNCTION getPiocheSize : INTEGER;
FUNCTION maxPiocheSize : INTEGER;
FUNCTION copyGrille(a : grille) : grille;
PROCEDURE log(text : STRING);
PROCEDURE redimensionnerGrille(VAR g : grille);
FUNCTION copyMain(main : tabPion) : tabPion;
FUNCTION copyTabPos(main : tabPos) : tabPos;
PROCEDURE delayy(s : INTEGER);

IMPLEMENTATION
VAR
	globalPioche : typePioche;
	globalIndexPioche : INTEGER;
	globalHumain : INTEGER;
	globalMachine : INTEGER;
	gNbrCouleurs, gNbrFormes, gNbrTuiles : INTEGER;

	PROCEDURE delayy(s : INTEGER);
	BEGIN
		delay(s);
	END;

	FUNCTION copyGrille(a : grille) : grille;
	VAR
		i, j : INTEGER;
		newGrille : grille;
	BEGIN
		setLength(newGrille, length(a), length(a));
		FOR i := 0 TO length(a) - 1 DO
		BEGIN
			FOR j := 0 TO length(a) - 1 DO
			BEGIN
				newGrille[i, j] := a[i, j];
			END;
		END;
		
		copyGrille := newGrille;
	END;

	PROCEDURE log(text : STRING);
	BEGIN
		writeln(text);
		readln();
	END;

	FUNCTION getPiocheSize : INTEGER;
	BEGIN
		getPiocheSize := gNbrFormes * gNbrTuiles * gNbrCouleurs - globalIndexPioche;
	END;
	
	FUNCTION maxPiocheSize : INTEGER;
	BEGIN
		maxPiocheSize := gNbrFormes * gNbrTuiles * gNbrCouleurs;
	END;

	PROCEDURE echangerPion(VAR main : tabPion; p : pion);
	VAR
		i, rand : INTEGER;
		tmp : pion;
	BEGIN
		IF globalIndexPioche + 1 < gNbrCouleurs * gNbrFormes * gNbrTuiles THEN
		BEGIN
			FOR i := 0 TO length(main) - 1 DO
			BEGIN
				IF (main[i].couleur = p.couleur) AND (main[i].forme = p.forme)THEN
				BEGIN
					rand := random(globalIndexPioche);
					tmp := main[i];
					main[i] := globalPioche[rand];
					globalPioche[rand] := tmp;
				END;
			END;
		END;
	END;

	PROCEDURE initPioche(nbrCouleurs, nbrFormes, nbrTuiles : INTEGER);
	VAR
		piocheIndex, i, j, k : INTEGER;
	BEGIN
		setLength(globalPioche, nbrCouleurs * nbrFormes * nbrTuiles);
		piocheIndex := 0;
		gNbrFormes := nbrFormes;
		gNbrTuiles := nbrTuiles;
		gNbrCouleurs := nbrCouleurs;
		globalIndexPioche := 0;

		// génération des pions en fonction des paramètres de départ
		FOR i := 0 TO nbrTuiles - 1 DO
		BEGIN
			FOR j := 1 TO nbrFormes DO
			BEGIN
				FOR k := 1 TO nbrCouleurs DO
				BEGIN
					globalPioche[piocheIndex].couleur := k;
					globalPioche[piocheIndex].forme   := j;
					inc(piocheIndex);
				END;
			END;
		END;
	END;

	PROCEDURE swap(a,b : INTEGER);
	VAR
		tmp : pion;
	BEGIN
		tmp := globalPioche[a];
		globalPioche[a] := globalPioche[b];
		globalPioche[b] := tmp;
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

	PROCEDURE swapLastMain(VAR main : tabPion; a: INTEGER);
	VAR
		tmp : pion;
	BEGIN
		tmp := main[a];
		main[a] := main[length(main) - 1];
		main[length(main) - 1] := tmp;
	END;

	PROCEDURE shufflePioche;
	VAR
		i : INTEGER;
	BEGIN
		Randomize;
		FOR i := 0 TO (length(globalPioche) - 1) * 3 DO
		BEGIN
			swap(random(length(globalPioche) - 1), random(length(globalPioche) - 1));
		END;
	END;

	// on agrandit la grille de 1 par 1
	PROCEDURE redimensionnerGrille(VAR g : grille);
	VAR
		tmpGrille : grille;
		i, j : INTEGER;
	BEGIN
		tmpGrille := copyGrille(g);
		setLength(g, length(g) + 2, length(g) + 2);
		FOR i := 0 TO length(tmpGrille) - 1 DO
		BEGIN
			FOR j := 0 TO length(tmpGrille) - 1 DO
			BEGIN
				g[i + 1, j + 1] := PION_NULL;
				g[i + 1, j + 1] := tmpGrille[i,j];
			END;
		END;
	END;

	PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
	BEGIN
		IF (x < 1) OR (y < 1) OR (y > length(g) - 2) OR (x > length(g) - 2)THEN
		BEGIN
			redimensionnerGrille(g);
			IF (x < 1) OR (y < 1) THEN
				g[x + 1, y + 1] := pionAAjouter;
			IF (y > length(g) - 1) OR (x > length(g) - 1) THEN
				g[x, y] := pionAAjouter;
		END
		ELSE
		BEGIN
			g[x,y] := pionAAjouter;
		END;
	END;

	FUNCTION remplirGrille(): grille;
	VAR
		i , j    : INTEGER;
		g        : grille;
	BEGIN
		setLength(g, 20, 20);
		FOR i := 0 TO 20 -1 DO
		BEGIN
			FOR j := 0 TO 20 -1 DO
			BEGIN
				g[i,j].couleur := COULEUR_NULL;
				g[i,j].forme   := FORME_NULL;
			END;
		END;
		remplirGrille := g;
	END;

	FUNCTION removeFromArray(main : tabPion; i : INTEGER) : tabPion;
	BEGIN
		swapLastMain(main, i);
		setLength(main, length(main) - 1);
		removeFromArray := main;
	END;

	PROCEDURE removePionFromMain(VAR main : tabPion; p : pion);
	VAR
		i, indexToRemove : INTEGER;
	BEGIN
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			IF (p.couleur = main[i].couleur) and (p.forme = main[i].forme) THEN
				indexToRemove := i;
		END;
		main := removeFromArray(main, indexToRemove);
	END;

	PROCEDURE initJoueur(nbrJoueurHumain, nbrJoueurMachine : INTEGER);
	BEGIN
		globalHumain  := nbrJoueurHumain;
		globalMachine := nbrJoueurMachine;
	END;

	FUNCTION piocher : pion;
	BEGIN
		IF globalIndexPioche < gNbrCouleurs * gNbrFormes * gNbrTuiles THEN
		BEGIN
			inc(globalIndexPioche);
			piocher := globalPioche[globalIndexPioche];
		END
		ELSE
			piocher := PION_NULL;
	END;

	FUNCTION creerMain: tabPion;
	VAR
		main : tabPion;
		i : INTEGER;
	BEGIN
		setLength(main, 6);
		FOR i := 0 TO 5 DO
			main[i] := piocher;
		creerMain := main;
	END;
END.
