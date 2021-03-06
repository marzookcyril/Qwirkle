UNIT constants;
INTERFACE
	CONST
		// CONSTANTES DU MOTEUR DAFFICHAGE
		
		FOR_TAB : ARRAY [0..12] OF STRING  = ('  ','{}','**','++', ')(','[]','##', '<>', '><', 'OO', '||', '/\', '@@');

		NUMBERED_COLS    = FALSE;

		TAILLE_GRILLE    = 75;

		// CONSTANTES DU MOTEUR DE JEU
		COULEUR_ROUGE  = 1;
		COULEUR_VERT   = 2;
		COULEUR_ORANGE = 3;
		COULEUR_CYAN   = 4;
		COULEUR_VIOLET = 5;
		COULEUR_BLEU   = 6;
		COULEUR_NULL   = 0;

		FORME_ROND     = 1; // {}
		FORME_TREFLE   = 2; // **
		FORME_ETOILE   = 3; // ++
		FORME_CROIX    = 4; // )(
		FORME_CARRE    = 5; // []
		FORME_LOSANGE  = 6; // ##
		FORME_NULL     = 0; //

		COL_BLACK    = 0;
		COL_BLUE     = 1;
		COL_GREEN    = 2;
		COL_CYAN     = 3;
		COL_RED      = 4;
		COL_MAGENTA  = 5;
		COL_BROWN    = 6;
		COL_LGRAY    = 7;
		COL_DGRAY    = 8;
		COL_LBLUE    = 9;
		COL_LGREEN   = 10;
		COL_LCYAN    = 11;
		COL_LRED     = 12;
		COL_LMAGENTA = 13;
		COL_YELLOW   = 14;
		COL_WHITE    = 15;

IMPLEMENTATION
END.
