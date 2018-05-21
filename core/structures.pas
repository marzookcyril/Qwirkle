UNIT structures;
INTERFACE
	USES constants;

	
	
	TYPE 	
		pion = RECORD
			couleur : INTEGER;
			forme   : INTEGER;
		END;
		
		grille = ARRAY [0..TAILLE_GRILLE, 0..TAILLE_GRILLE] OF pion;
	
	
IMPLEMENTATION
END.
