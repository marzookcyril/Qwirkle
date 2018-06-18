UNIT UIGraphic;
INTERFACE

USES glib2d, SDL_TTF , sysutils, structures;

TYPE
	tabImage = ARRAY [0..35] OF gImage;

CONST
	xTab = 50;
	yTab = 50;
	
	TAB_IMAGE: Array[0..35] of String = ('rCarre.png', 'vertCarre.png', 'bCarre.png', 'yCarre.png', 'vCarre.png', 'oCarre.png', 'rLosange.png', 'vertLosange.png', 'bLosange.png', 'yLosange.png', 'vLosange.png', 'oLosange.png', 'rRond.png', 'vertRond.png', 'bRond.png', 'yRond.png', 'vRond.png','oRond.png', 'rEtoile.png', 'vertEtoile.png', 'bEtoile.png', 'yEtoile.png', 'vEtoile.png', 'oEtoile.png', 'rTache.png', 'vertTache.png', 'bTache.png', 'yTache.png', 'vTache.png', 'oTache.png', 'rTrefle.png', 'vertTrefle.png', 'bTrefle.png', 'yTrefle.png', 'vTrefle.png', 'oTrefle.png');

PROCEDURE renderGrilleUI(g : grille);

IMPLEMENTATION
	
	FUNCTION loadImagePion : tabImage;
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO length(TAB_IMAGE) - 1 DO
			loadImagePion[i] := gTexLoad('pions/' + TAB_IMAGE[i]);
	END;
	
	PROCEDURE afficherImage(image : gImage; x,y,t : INTEGER);
	BEGIN
		gBeginRects(image);
			gSetCoordMode(G_CENTER);
			gSetAlpha(255);
			gSetScaleWH(t, t);
			gSetCoord(x, y);
			gSetRotation(0);
			gAdd;
		gEnd;
	END;
	
	PROCEDURE renderGrilleUI(g : grille);
	VAR
		i, j, taille : INTEGER;
		tab : tabImage;
	BEGIN
		taille := (40*20) DIV length(g);
		tab := loadImagePion;
        FOR i := 0 TO length(g) - 1 DO
        BEGIN
            FOR j := 0 TO length(g) - 1 DO
            BEGIN
				afficherImage(tab[(i + j) MOD 35], xTab + i * taille, yTab + j * taille, taille);
            END;
        END;
	END;
END.
