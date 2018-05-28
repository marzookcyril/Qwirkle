UNIT structures;
INTERFACE
	USES constants;

	{
	TYPES :
		- pion       : type du pion primitif
		- grille     : grille globale de la partie
		- mainJoueur : main du joueur
		- mainJoueur : pioche générale
	}

	TYPE
		pion = RECORD
			couleur : INTEGER;
			forme   : INTEGER;
		END;

		grille     = ARRAY [0..TAILLE_GRILLE - 1, 0..TAILLE_GRILLE - 1] OF pion;
		mainJoueur = ARRAY [0..6 - 1] OF pion;
		typePioche = ARRAY [0..108] OF pion;

		position = RECORD
			x : INTEGER;
			y : INTEGER;
			END;
		tabdyn = ARRAY OF INTEGER;

		dataHistorique = RECORD
              id     : INTEGER;
              joueur : STRING;
              pion   : pion;
              posX   : INTEGER;
              posY   : INTEGER;
      	END;

IMPLEMENTATION
END.
