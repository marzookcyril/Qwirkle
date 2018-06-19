UNIT UIGraphic;
INTERFACE

USES glib2d, SDL_TTF , sysutils, structures, game;

TYPE
	tabImage = ARRAY [0..35] OF gImage;

CONST
	xTab = 50;
	yTab = 50;
	xMain = 1000;
	yMain = 750;
	
	TAB_IMAGE: Array[0..35] of String = ('bRond.png','bTrefle.png','bEtoile.png','bTache.png','bCarre.png','bLosange.png','vertRond.png','vertTrefle.png','vertEtoile.png','vertTache.png','vertCarre.png','vertLosange.png','bRond.png','bTrefle.png','bEtoile.png','bTache.png','bCarre.png','bLosange.png','rRond.png','rTrefle.png','rEtoile.png','rTache.png','rCarre.png','rLosange.png','vRond.png','vTrefle.png','vEtoile.png','vTache.png','vCarre.png','vLosange.png','oRond.png','oTrefle.png','oEtoile.png','oTache.png','oCarre.png','oLosange.png');
	

PROCEDURE renderGrilleUI(g : grille);
PROCEDURE loadImagePion;
PROCEDURE renderMainUI(main : tabPion);
FUNCTION placerPion(g : grille; main : tabPion) : typeCoup;
FUNCTION supprimerPion(g : grille; main : tabPion) : tabPion;

IMPLEMENTATION
VAR
	TAB_IMAGE_LOAD : tabImage;
	poubelle : gImage;
	tick : gImage;
	
	PROCEDURE clearScreen();
	BEGIN
		gClear(WHITE);
	END;
	
	PROCEDURE loadImagePion;
	VAR
		i : INTEGER;
	BEGIN
		poubelle := gTexLoad('poubelle.png');
		tick := gTexLoad('tick.png');
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
							
							afficherImage(TAB_IMAGE_LOAD[(g[i, j].couleur - 1) * 6 + g[i, j].forme - 1], xTab + i * taille + taille DIV 2, yTab + j * taille + taille DIV 2, taille);
						END;
					END;
				END;
			END;
		END
		ELSE
			writeln('TROP GRANDE GRILLE');
	END;
	
	PROCEDURE renderMainUI(main : tabPion);
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			gFillRect(xMain + i * 40, yMain, 40, 40, WHITE);
			gDrawRect(xMain + i * 40, yMain, 40, 40, BLACK);
			afficherImage(TAB_IMAGE_LOAD[(main[i].couleur - 1) * 6 + main[i].forme - 1], xMain + i * 40 + 20, yMain + 20, 40);
		END;
	END;
	
	FUNCTION getPos(x,y,xMin,yMin,xMax,yMax,t : INTEGER) : position;
	BEGIN
		IF (x > xMin) AND (x < xMax) AND (y > yMin) AND (y < yMax) THEN
		BEGIN
			getPos.x := (x - xMin) DIV t + 1;
			getPos.y := (y - yMin) DIV t + 1; 
		END
		ELSE
		BEGIN
			getPos.x := - 1;
			getPos.y := - 1; 
		END;
	END;

	FUNCTION supprimerPion(g : grille; main : tabPion) : tabPion;
	VAR
		hasFinished, stop : BOOLEAN;
		tmpMain   : tabPion;
		choose : position;
		taille : INTEGER;
	BEGIN
		hasFinished := False;
		stop := false;
		tmpMain   := copyMain(main);
		setLength(supprimerPion, 0);
		REPEAT
		
			clearScreen;
			renderGrilleUI(g);
			
			IF stop THEN
			BEGIN
				delayy(300);
				stop := false;
			END;
			
			afficherImage(poubelle, xMain + 40 * 7 + 20, yMain + 20, 40);
			afficherImage(tick, xMain + 40 * 8 + 20, yMain + 20, 40);
			
			taille := (40*20) DIV length(g);
			while (sdl_update = 1) do
				if (sdl_do_quit) then
					exit;
			renderMainUI(tmpMain);
			
			IF sdl_mouse_left_down THEN
			BEGIN
				choose := getPos(sdl_get_mouse_x, sdl_get_mouse_y, xMain, yMain,xMain + length(main) * 40, yMain + 40, 40);
			END;
			
			IF (choose.x <> -1) AND sdl_get_left_mouse_pressed THEN
			BEGIN
				afficherImage(TAB_IMAGE_LOAD[(main[choose.x - 1].couleur - 1) * 6 + main[choose.x - 1].forme - 1], sdl_get_mouse_x, sdl_get_mouse_y, 40);
			END;
			
			IF (choose.x <> -1) AND NOT sdl_get_left_mouse_pressed AND (getPos(sdl_get_mouse_x, sdl_get_mouse_y, xMain + 7 * 40, yMain, xMain + 8 * 40, yMain + 40, 40).x = 1) THEN
			BEGIN
				writeln('je sius la fdp');
				setLength(supprimerPion, length(supprimerPion) + 1);
				supprimerPion[length(supprimerPion) + 1] := tmpMain[choose.x - 1];
				
				removePionFromMain(tmpMain, tmpMain[choose.x - 1]);
				stop := True;
			END;
			
			IF sdl_mouse_left_down AND (getPos(sdl_get_mouse_x, sdl_get_mouse_y, xMain + 8 * 40, yMain, xMain + 9 * 40, yMain + 40, 40).x = 1) THEN
				hasFinished := True;
			
			
			gFlip();
		UNTIL hasFinished;
	END;

	FUNCTION placerPion(g : grille; main : tabPion) : typeCoup;
	VAR
		hasPlaced : BOOLEAN;
		tmpMain   : tabPion;
		choose : position;
		taille : INTEGER;
	BEGIN
		
		hasPlaced := False;
		tmpMain := copyMain(main);
		taille := (40*20) DIV length(g);
		choose.x := -1;
		
		REPEAT
			clearScreen;
			renderGrilleUI(g);
			while (sdl_update = 1) do
				if (sdl_do_quit) then
					exit;
		
			writeln('dans la boucle',sdl_mouse_left_down);
			renderMainUI(main);
			IF sdl_mouse_left_down THEN
			BEGIN
				choose := getPos(sdl_get_mouse_x, sdl_get_mouse_y, xMain, yMain,xMain + length(main) * 40, yMain + 40, 40);
				writeln('pressed', choose.x);
			END;
			IF (choose.x <> -1) AND sdl_get_left_mouse_pressed THEN
			BEGIN
				afficherImage(TAB_IMAGE_LOAD[(main[choose.x - 1].couleur - 1) * 6 + main[choose.x - 1].forme - 1], sdl_get_mouse_x, sdl_get_mouse_y, 40);
			END;
			
			IF (choose.x <> -1) AND NOT sdl_get_left_mouse_pressed THEN
			BEGIN
				hasPlaced := True;
				setLength(placerPion.pos, 1);
				setLength(placerPion.p, 1);
				placerPion.pos[0] := getPos(sdl_get_mouse_x, sdl_get_mouse_y, xTab, yTab, xTab + length(g) * taille, yTab + length(g) * taille, taille);
				placerPion.p[0]   := main[choose.x - 1];
			END;
			
			gFlip();
		UNTIL hasPlaced;
	END;
END.
