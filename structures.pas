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
	
		couleur =  RECORD
			col1 : INTEGER;
			col2 : INTEGER;
		END;

		grille     = ARRAY OF ARRAY OF pion;
		typePioche = ARRAY OF pion;

		position = RECORD
			x : INTEGER;
			y : INTEGER;
		END;

		tabdyn = ARRAY OF INTEGER;
		tabPos = ARRAY OF position;
		tabPion = ARRAY OF pion;

		typeCoup   = RECORD
			pos : tabPos;
			p   : tabPion;
		END;

		tabCoups = ARRAY OF typeCoup;

		typeJoueur = RECORD
			main : tabPion;
			genre : BOOLEAN;
			score : INTEGER;
		END;

		tabJoueur = ARRAY OF typeJoueur;


		dataHistorique = RECORD
              id     : INTEGER;
              joueur : STRING;
              pion   : pion;
              posX   : INTEGER;
              posY   : INTEGER;
      	END;

CONST
	PION_NULL : pion = (couleur: COULEUR_NULL; forme: FORME_NULL);
	PION_ROUGE : pion = (couleur: COL_RED; forme: 12);
	PION_FLECHE : pion = (couleur : 7; forme: 11);

IMPLEMENTATION
END.
