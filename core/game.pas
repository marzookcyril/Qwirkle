UNIT game;
INTERFACE
USES constants, structures,crt,
	console in '../uix/consoleUI/console.pas';

PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
FUNCTION remplirGrille(): grille;
FUNCTION initPioche : typePioche;
PROCEDURE shufflePioche(VAR pioche : typePioche);
PROCEDURE raccourcirPioche(VAR pioche : typePioche);
FUNCTION creerMain(pioche : typePioche): mainJoueur;
PROCEDURE echangerPion(VAR main : mainJoueur; VAR pioche : typePioche; n : INTEGER);
PROCEDURE afficheMain( g:grille ; x,y : INTEGER ; main : mainJoueur);


IMPLEMENTATION

	FUNCTION initPioche : typePioche;
	VAR
		pioche   : typePioche;
		piocheIndex, i, j, k : INTEGER;
	BEGIN
		piocheIndex := 0;
		// tous les pions sont en triple
		FOR i := 0 TO 2 DO
		BEGIN
			FOR j := 1 TO 6 DO
			BEGIN
				FOR k := 1 TO 6 DO
				BEGIN
					pioche[piocheIndex].couleur := k;
					pioche[piocheIndex].forme   := j;
					inc(piocheIndex);
				END;
			END;
		END;
		initPioche := pioche;
	END;

	PROCEDURE swap(VAR pioche : typePioche; a,b : INTEGER);
	VAR
		tmp : pion;
	BEGIN
		tmp := pioche[a];
		pioche[a] := pioche[b];
		pioche[b] := tmp;
	END;

	PROCEDURE shufflePioche(VAR pioche : typePioche);
	VAR
		i : INTEGER;
	BEGIN
		Randomize;
		FOR i := 0 TO SHUFFLE_PRECISION DO
		BEGIN
			swap(pioche, random(107), random(107));
		END;
	END;

	// Quand on ajoute un pion à la grille on est sur que ce pion peut etre joué;
	PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER; joueur : STRING);
	BEGIN
		clrscr;
		g[x,y] := pionAAjouter;
		addToHistorique(pionAAjouter, x, y, joueur);
		renderGame(g);
	END;

	// Fonction qui permet d'initier une grille
	// avec des formes et couleurs nulle
	FUNCTION remplirGrille(): grille;
	VAR
		i , j    : INTEGER;
		g        : grille;
	BEGIN
		FOR i := 0 TO TAILLE_GRILLE -1 DO
		BEGIN
			FOR j := 0 TO TAILLE_GRILLE -1 DO
			BEGIN
				g[i,j].couleur := COULEUR_NULL;
				g[i,j].forme   := FORME_NULL;
			END;
		END;
		remplirGrille := g;
	END;
	
	PROCEDURE raccourcirPioche(VAR pioche : typePioche);
	VAR i,j : INTEGER;
	BEGIN	
		i :=0;
		j :=0;
		WHILE i <> 1 DO 
		BEGIN
			IF pioche[j].couleur = 0 THEN 
				inc(j)
			ELSE 
			BEGIN
				pioche[j].couleur := 0;
				inc(i);
			END;
		END;
	END;
	
	FUNCTION creerMain(pioche : typePioche): mainJoueur;
	VAR main : mainJoueur;
		i : INTEGER;
	BEGIN
		i := 0;
		WHILE i <> 6 DO  
		BEGIN
			iF pioche[i].couleur <> 0 THEN 
			BEGIN
				main[i] := pioche[i];
				raccourcirPioche(pioche);
				inc(i);
			END;
		END;
		creerMain := main;
	END;
	
	PROCEDURE afficheMain( g:grille ; x,y : INTEGER ; main : mainJoueur);
	VAR i , j : INTEGER;
	BEGIN
		j :=0;
		FOR i := 0 TO 5 DO 
		BEGIN
			ajouterPion(g,main[i],x+j,y,'');
			j := j+3;
			END;
	END;
	
	
	PROCEDURE echangerPion(VAR main : mainJoueur; VAR pioche: typePioche ; n : INTEGER);
	VAR p : pion;
		i,j : INTEGER;
	BEGIN
		i :=0;
		j :=0;
		WHILE i <> 1 DO 
		BEGIN
			IF pioche[j].couleur = 0 THEN 
				inc(j)
			ELSE 
			BEGIN
				p.couleur     := main[n].couleur;
				p.forme       := main[n].forme;
				main[n].couleur   := pioche[j].couleur;
				main[n].forme   := pioche[j].forme;
				pioche[j].couleur := p.couleur;
				pioche[j].forme := p.forme;
			END;
		END;
	END;
	
END.
