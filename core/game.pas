UNIT game;
INTERFACE
USES constants, structures,crt,
	 console in './uix/consoleUI/console.pas';
	
PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER);
FUNCTION remplirGrille(): grille;

IMPLEMENTATION
	
	// Quand on ajoute un pion à la grille on est sur que ce pion peut etre joué;
	PROCEDURE ajouterPion(VAR g : grille; pionAAjouter : pion; x,y : INTEGER);
	BEGIN
		clrscr;
		g[x,y] := pionAAjouter;
		renderGame(g);
	END;
	
	
	// Fonction qui permet d'initier une grille
	// avec des formes et couleurs nulle
	 
	FUNCTION remplirGrille(): grille;
	VAR 
		i , j    : INTEGER;
		g        : grille;
		pionNull : pion;
	BEGIN
		pionNull.couleur := COULEUR_NUL;
		pionNull.forme   := FORME_NUL;
		FOR i := 0 TO TAILLE_GRILLE -1 DO 
		BEGIN
			FOR j := 0 TO TAILLE_GRILLE -1 DO 
			BEGIN
				g[i,j] := pionNull;
			END;
		END;
		remplirGrille := g;
	END;
	
END.
