UNIT UIGraphic;
INTERFACE

USES glib2d, SDL_TTF , sysutils, structures;

TYPE
	tabImage = ARRAY [0..35] OF gImage;

CONST
	xTab = 50;
	yTab = 50;
	
	
	TAB_IMAGE: Array[0..35] of String = ('bRond.png','bTrefle.png','bEtoile.png','bTache.png','bCarre.png','bLosange.png','vertRond.png','vertTrefle.png','vertEtoile.png','vertTache.png','vertCarre.png','vertLosange.png','bRond.png','bTrefle.png','bEtoile.png','bTache.png','bCarre.png','bLosange.png','rRond.png','rTrefle.png','rEtoile.png','rTache.png','rCarre.png','rLosange.png','vRond.png','vTrefle.png','vEtoile.png','vTache.png','vCarre.png','vLosange.png','oRond.png','oTrefle.png','oEtoile.png','oTache.png','oCarre.png','oLosange.png');
	

PROCEDURE renderGrilleUI(g : grille);
PROCEDURE loadImagePion;

IMPLEMENTATION
VAR
	TAB_IMAGE_LOAD : ARRAY [0..35] OF gImage;
	
	PROCEDURE loadImagePion;
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO length(TAB_IMAGE) - 1 DO
			TAB_IMAGE_LOAD[i] := gTexLoad('pions/' + TAB_IMAGE[i]);
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
	BEGIN
		IF length(g) < 50 THEN
		BEGIN
			taille := (40*20) DIV length(g);
			FOR i := 0 TO length(g) - 1 DO
			BEGIN
				FOR j := 0 TO length(g) - 1 DO
				BEGIN
					IF g[i, j].forme = 0 THEN
					BEGIN
						gFillRect(xTab + i * taille, yTab + j * taille, taille, taille, WHITE);
						gDrawRect(xTab + i * taille, yTab + j * taille, taille, taille, BLACK);
						
					END
					ELSE
					BEGIN
						IF (g[i, j].couleur - 1) * 6 + g[i, j].forme < 37 THEN
						BEGIN
							
							afficherImage(TAB_IMAGE_LOAD[(g[i, j].couleur - 1) * 6 + g[i, j].forme], xTab + i * taille + taille DIV 2, yTab + j * taille + taille DIV 2, taille);
						END;
					END;
				END;
			END;
		END
		ELSE
			writeln('TROP GRANDE GRILLE');
	END;
END.
