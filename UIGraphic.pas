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
	xScore = 1000;
	yScore = 300;
	
	TAB_IMAGE: Array[0..35] of String = ('bRond.png','bTrefle.png','bEtoile.png','bTache.png','bCarre.png','bLosange.png','vertRond.png','vertTrefle.png','vertEtoile.png','vertTache.png','vertCarre.png','vertLosange.png','yRond.png','yTrefle.png','yEtoile.png','yTache.png','yCarre.png','yLosange.png','rRond.png','rTrefle.png','rEtoile.png','rTache.png','rCarre.png','rLosange.png','vRond.png','vTrefle.png','vEtoile.png','vTache.png','vCarre.png','vLosange.png','oRond.png','oTrefle.png','oEtoile.png','oTache.png','oCarre.png','oLosange.png');
	

PROCEDURE renderGrilleUI(g : grille);
PROCEDURE loadImagePion;
PROCEDURE renderMainUI(main : tabPion);
PROCEDURE renderScoreUI(allJoueur : tabJoueur; joueurJouant : INTEGER);
FUNCTION faireJoueurJoueur(g : grille; main : tabPion; allJoueur : tabJoueur; joueurJouant : INTEGER; isFirst : BOOLEAN) : typeCoup;
PROCEDURE clearScreen();
PROCEDURE afficherText(str : STRING; x,y,t : INTEGER; c : gColor);

IMPLEMENTATION
VAR
	TAB_IMAGE_LOAD : tabImage;
	poubelle : gImage;
	tick : gImage;
	reset : gImage;
	qwirkle : gImage;
	font1,font2,font3,font4,font5 : PTTF_Font;
	
	PROCEDURE clearScreen();
	BEGIN
		gClear(WHITE);
	END;
	
	PROCEDURE loadImagePion;
	VAR
		i : INTEGER;
	BEGIN
		poubelle := gTexLoad('poubelle.png');
		tick     := gTexLoad('tick.png');
		reset    := gTexLoad('reset.png');
		qwirkle  := gTexLoad('Qwirkle.png');
		font1    := TTF_OpenFont('police.ttf', 20);
		font2    := TTF_OpenFont('police.ttf', 30);
		font3    := TTF_OpenFont('police.ttf', 40);
		font4    := TTF_OpenFont('police.ttf', 50);
		font5    := TTF_OpenFont('police.ttf', 60);
		FOR i := 0 TO length(TAB_IMAGE) - 1 DO
			TAB_IMAGE_LOAD[i] := gTexLoad('pions/' + TAB_IMAGE[i]);
	END;
	
	// on affiche l'image a une position donné 
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
	
	//  on affiche l'image en tant que rectangle a une position donné 
	PROCEDURE afficherImageRect(image : gImage; x,y,t1,t2 : INTEGER);
	BEGIN
		gBeginRects(image);
			gSetCoordMode(G_UP_LEFT);
			gSetAlpha(255);
			gSetScaleWH(t1, t2);
			gSetCoord(x, y);
			gSetRotation(0);
			gAdd;
		gEnd;
	END;
	
	// permet d'afficher un texte d'une couleur et a position donné 
	PROCEDURE afficherText(str : STRING; x,y,t : INTEGER; c : gColor);
	VAR
		text : gImage;
	BEGIN
		CASE t OF
			1: text := gTextLoad(str, font1);
			2: text := gTextLoad(str, font2);
			3: text := gTextLoad(str, font3);
			4: text := gTextLoad(str, font4);
			5: text := gTextLoad(str, font5);
		END;
		gBeginRects(text);
            gSetCoordMode(G_UP_LEFT);
            gSetCoord(x, y);
            gSetColor(c);
            gSetRotation(0);
            gAdd();
        gEnd();

	END;
	
	// on affiche ici le scire sous forme de texte 
	FUNCTION createScoreText(joueur : typeJoueur; id : INTEGER) : STRING;
	BEGIN
		IF joueur.genre THEN
			createScoreText := 'Humain n' + inttostr(id) + ': ' + inttostr(joueur.score)
		ELSE
			createScoreText := 'AI n' + inttostr(id) + ': ' + inttostr(joueur.score);
	END;
	
	// on utlise la fonction precedente pour afficher le scire des joueurs 
	PROCEDURE renderScoreUI(allJoueur : tabJoueur; joueurJouant : INTEGER);
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO length(allJoueur) - 1 DO
		BEGIN
			IF i = joueurJouant THEN
				afficherText(createScoreText(allJoueur[i], i + 1), xScore, yScore + i * 30, 2, RED)
			ELSE
				afficherText(createScoreText(allJoueur[i], i + 1), xScore, yScore + i * 30, 2, GRAY);
		END;
	END;
	
	// on affiche la grille tout en rendanr les cases rouges si on passe la souris dessus 
	PROCEDURE renderGrilleUI(g : grille);
	VAR
		i, j, taille : INTEGER;
	BEGIN
		afficherImageRect(qwirkle, 1050, 100, 550, 113);
		afficherText('par Paul & Cyril!', 1450, 210, 2, DARKGRAY);
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
			afficherText('GRILLE TROP GRANDE', xTab + 100, yTab + 250, 4, RED);
	END;
	
	// on afficge les pions a partir des images dans le dossier pions 
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
	
	// on prend les position du pions que l'on glisse dans la grille 
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

	//  permet de supprimer le pion selectione 
	FUNCTION boutonSupprimer : BOOLEAN;
	BEGIN
		boutonSupprimer := (getPos(sdl_get_mouse_x, sdl_get_mouse_y, xMain + 9 * 40, yMain, xMain + 10 * 40, yMain + 40, 40).x = 1);
	END;

	FUNCTION boutonValider : BOOLEAN;
	BEGIN
		boutonValider := (getPos(sdl_get_mouse_x, sdl_get_mouse_y, xMain + 8 * 40, yMain, xMain + 9 * 40, yMain + 40, 40).x = 1);
	END;
	
	FUNCTION boutonReset : BOOLEAN;
	BEGIN
		boutonReset := (getPos(sdl_get_mouse_x, sdl_get_mouse_y, xMain + 10 * 40, yMain, xMain + 11 * 40, yMain + 40, 40).x = 1);
	END;
	
	// -1 -> est pas dans la main
	// entre 0 et tailleDeMain -> retourne le pion sur lequel on est
	FUNCTION pionDeLaMain (main : tabPion) : INTEGER;
	VAR
		resultatGetPos : INTEGER;
	BEGIN
		resultatGetPos := getPos(sdl_get_mouse_x, sdl_get_mouse_y, xMain, yMain, xMain + length(main) * 40, yMain + 40, 40).x;
		IF (resultatGetPos > 0) AND (resultatGetPos <= length(main)) THEN
			pionDeLaMain := resultatGetPos
		ELSE
			pionDeLaMain := -1;
	END;
	
	FUNCTION posGrille (taillePion, tailleGrille : INTEGER) : position;
	BEGIN
		posGrille := getPos(sdl_get_mouse_x, sdl_get_mouse_y, xTab, yTab, tailleGrille, tailleGrille, taillePion);
	END;
	
	PROCEDURE renderToCursor(img : gImage);
	BEGIN
		afficherImage(img, sdl_get_mouse_x, sdl_get_mouse_y, 40);
	END;

	// fait tourner le joueur contre joueur danc de glib2d
	FUNCTION faireJoueurJoueur(g : grille; main : tabPion; allJoueur : tabJoueur; joueurJouant : INTEGER; isFirst : BOOLEAN) : typeCoup;
	VAR
		taille : INTEGER;
		hasPlay, renderCursor, aJoueUneFois : BOOLEAN;
		test : typeCoup;
		tmpGrille : grille;
		tmpMain   : tabPion;
		pionCursor : pion;
		typeCoup : INTEGER;
	BEGIN
		hasPlay := False;
		tmpGrille := copyGrille(g);
		tmpMain   := copyMain(main);
		typeCoup  := 0; // 1 -> est en train de supprimer 2 -> est en train de placer des pions 0 -> n'a rien choisis
		renderCursor := False;
		aJoueUneFois := False;
		
		setLength(test.p, 0);
		setLength(test.pos, 0);
		
		REPEAT
			taille := (40*20) DIV length(tmpGrille);
			clearScreen;
		
			while (sdl_update = 1) do
				if (sdl_do_quit) then
					exit;
		
			renderGrilleUI(tmpGrille);
			renderMainUI(tmpMain);
			renderScoreUI(allJoueur, joueurJouant);
			afficherImage(tick, xMain + 8 * 40 + 20, yMain + 20, 40);
			afficherImage(reset, xMain + 10 * 40 + 20, yMain + 20, 40);
			afficherImage(poubelle, xMain + 9 * 40 + 20, yMain + 20, 40);
			
			// fais un rendu du pion sur le curseur
			IF renderCursor THEN
				renderToCursor(TAB_IMAGE_LOAD[(pionCursor.couleur - 1) * 6 + pionCursor.forme - 1]);
			
			// prend un pion dans la main
			IF (pionDeLaMain(tmpMain) <> -1) AND sdl_mouse_left_down THEN
			BEGIN
				renderCursor := True;
				pionCursor := tmpMain[pionDeLaMain(tmpMain) - 1]; 
			END;
			
			//supprimer des pions
			IF renderCursor AND ((typeCoup = 0) OR (typeCoup = 1)) AND boutonSupprimer AND NOT sdl_get_left_mouse_pressed THEN
			BEGIN
				typeCoup := 1;
				setLength(test.p, length(test.p) + 1);
				test.p[high(test.p)] := pionCursor;
				removePionFromMain(tmpMain, pionCursor);
				renderCursor := False;
				aJoueUneFois := True;
			END;
			
			// mettre des pions dans la grille
			IF renderCursor AND ((typeCoup = 0) OR (typeCoup = 2)) AND (posGrille(taille, xTab + length(tmpGrille) * taille).x <> -1) AND NOT sdl_get_left_mouse_pressed THEN
			BEGIN
				renderCursor := False;
				IF isFirst THEN
				BEGIN
					ajouterPion(tmpGrille, pionCursor, length(tmpGrille) DIV 2, length(tmpGrille) DIV 2);
					setLength(test.pos, length(test.pos) + 1);
					test.pos[high(test.pos)].x := length(tmpGrille) DIV 2 + 1;
					test.pos[high(test.pos)].y := length(tmpGrille) DIV 2 + 1;
					isFirst := False;
				END
				ELSE
				BEGIN
					ajouterPion(tmpGrille, pionCursor, posGrille(taille, xTab + length(tmpGrille) * taille).x - 1, posGrille(taille, xTab + length(tmpGrille) * taille).y - 1);
					setLength(test.pos, length(test.pos) + 1);
					test.pos[high(test.pos)] := posGrille(taille, xTab + length(tmpGrille) * taille);
				END;
				setLength(test.p, length(test.p) + 1);
				test.p[high(test.p)] := pionCursor;
				removePionFromMain(tmpMain, pionCursor);
				aJoueUneFois := True;
			END;
			
			// si on relache le bouton gauche, on arrete de prendre le pion
			IF renderCursor AND NOT sdl_get_left_mouse_pressed THEN
				renderCursor := False;
			
			// validation du tour
			IF NOT renderCursor AND boutonValider AND sdl_mouse_left_down AND aJoueUneFois THEN
			BEGIN
				writeln('fin du tour');
				hasPlay := True;
			END;
		
			// reset du tour
			IF NOT renderCursor AND boutonReset AND sdl_mouse_left_down AND aJoueUneFois THEN
			BEGIN
				hasPlay := False;
				tmpGrille := copyGrille(g);
				tmpMain   := copyMain(main);
				typeCoup  := 0;
				renderCursor := False;
				aJoueUneFois := False;
				setLength(test.p, 0);
				setLength(test.pos, 0);
			END;
			
			gFlip();
		UNTIL hasPlay;
		faireJoueurJoueur := test;
	END;
END.
