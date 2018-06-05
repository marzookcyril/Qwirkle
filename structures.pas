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
		mainJoueur = ARRAY OF pion;
		typePioche = ARRAY OF pion;

		typeJoueur = RECORD
			main : mainJoueur;
			genre : BOOLEAN;
			score : INTEGER;
		END;

		tabJoueur = ARRAY OF typeJoueur;

		position = RECORD
			x : INTEGER;
			y : INTEGER;
		END;
		tabdyn = ARRAY OF INTEGER;
		tabPos = ARRAY[0..5] OF position;

		dataHistorique = RECORD
              id     : INTEGER;
              joueur : STRING;
              pion   : pion;
              posX   : INTEGER;
              posY   : INTEGER;
      	END;

CONST
	PION_NULL : pion = (couleur: COULEUR_NULL; forme: FORME_NULL);

IMPLEMENTATION
END.
