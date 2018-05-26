{
* 	CETTE UNIT EST RESPONSABLE DE TOUT L'AFFICHAGE CONSOLE.
*   C'EST ELLE QUI GERE TOUT L'ECRAN DE LA CONSOLE.
*   ELLE NE GERE PAS LES INPUTS OU LE MOTEUR DU JEU.
*   ELLE NE FAIT QUE LE RENDU
* }

UNIT console;
INTERFACE

USES constants  in './core/constants.pas', crt,
	 structures in './core/structures.pas', sysutils;

TYPE
	// type primitif de tout ce qui peut être affiché à l'écran.
	printable = RECORD
		chr   : CHAR;
		tCol  : BYTE;
		bgCol : BYTE;
	END;
	
PROCEDURE render;
PROCEDURE renderGame(g : grille);
PROCEDURE renderMenuBorder();
PROCEDURE clearScreen (bgColor :  BYTE);
PROCEDURE renderPionInGrille(x,y : INTEGER; pion : pion);

IMPLEMENTATION
	VAR
		// Surface principale
		globalScreen : ARRAY [0..WIDTH - 1, 0..HEIGHT - 1] OF printable;
	
	// Affiche à l'écran le contenue de la surface générale (chez nous globalScreen)
	// en prenant en compte les couleurs et le BG.
	PROCEDURE render();
	VAR
		x,y : INTEGER;
	BEGIN
		FOR y := 0 TO HEIGHT - 1 DO
		BEGIN
			FOR x := 0 TO WIDTH - 1 DO
			BEGIN
				textcolor(globalScreen[x,y].tCol);
				TextBackground(globalScreen[x,y].bgCol);
				write(globalScreen[x,y].chr);
				textcolor(7);
				TextBackground(0);
			END;
			writeln;
		END;
	END;
	
	// Fais le rendu d'une ligne à la verticale ou à l'horizontale
	// Sont demandés en entrée les coordonnées des deux points des
	// extrémités de la ligne, la couleur de la ligne et son BG.
	PROCEDURE renderLine(x1, y1, x2, y2, tCol, bgCol : INTEGER);
	VAR
		x : INTEGER;
	BEGIN
		// ligne horizontale
		IF (x1 <> x2) and (y1 = y2) THEN
		BEGIN
			FOR x := x1 TO x2 DO
			BEGIN
				globalScreen[x, y1].chr   := '-';
				globalScreen[x, y1].tCol  := tCol;
				globalScreen[x, y1].bgCol := bgCol;
			END;
		END;
		
		// ligne verticale
		IF (x1 = x2) and (y1 <> y2) THEN
		BEGIN
			FOR x := y1 TO y2 DO
			BEGIN
				globalScreen[x1, x].chr   := '|';
				globalScreen[x1, x].tCol  := tCol;
				globalScreen[x1, x].bgCol := bgCol;
			END;
		END;
	END;
	
	// Vérifie si les coordonnées demandées sont dans l'écran ou non.
	// RETURN : TRUE si elles sont dans l'écran
	//        : FALSE si elles ne pas dans l'écran
	FUNCTION isInScreen(x,y : INTEGER) : BOOLEAN;
	BEGIN
		isInScreen := NOT((x < 0) or (x > WIDTH) or (y < 0) or (y > HEIGHT));
	END;
	
	// affiche un charactère à l'écran aux coordonnées x,y avec un texte de
	// couleur tCol et de bg bgCol (voir constantes.pas)
	PROCEDURE plot(chr : CHAR; x,y,tCol,bgCol : INTEGER);
	BEGIN
		IF isInScreen(x,y) THEN
		BEGIN
			globalScreen[x, y].bgCol := bgCol;
			globalScreen[x, y].tCol  := tCol;
			globalScreen[x, y].chr   := chr;
		END;
	END;
	
	// Créer les bordures du menu. Fait le rendu dans la surface globalScreen
	PROCEDURE renderMenuBorder();
	BEGIN
		renderLine(0, 0, WIDTH - 1, 0, 7, 0);
		renderLine(0, 0,         0, HEIGHT - 1, 7, 0);
		renderLine(0, HEIGHT - 1, WIDTH - 1, HEIGHT - 1, 7, 0);
		renderLine(WIDTH - 1, 0, WIDTH - 1, HEIGHT - 1, 7, 0);
		plot('+',0,0,7,0);
		plot('+',0,HEIGHT - 1,7,0);
		plot('+',WIDTH - 1,0,7,0);
		plot('+',WIDTH - 1,HEIGHT - 1,7,0);
	END;
	
	// Fais un simple rendu de texte aux coordonnées x,y avec un texte de
	// couleur tCol et de bg bgCol (voir constantes.pas)
	PROCEDURE renderText(text : STRING; x, y, tCol, bgCol : INTEGER);
	VAR
		i   : INTEGER;
		tmp : printable;
	BEGIN
		tmp.tCol  := tCol;
		tmp.bgCol := bgCol;
		FOR i := 1 TO length(text) DO
		BEGIN
			tmp.chr := text[i];
			globalScreen[i + x, y] := tmp;
		END;
	END;
	
	// ATTENTION !
	// on fait un rendu dans le référentiel de la grille, pas de l'écran.
	PROCEDURE renderPionInGrille(x,y : INTEGER; pion : pion);
	BEGIN
		plot(FOR_TAB[pion.forme,1], 2 * x - 1, y + 2, COL_WHITE, COL_TAB[pion.couleur]);
		plot(FOR_TAB[pion.forme,2],     2 * x, y + 2, COL_WHITE, COL_TAB[pion.couleur]);
	END;
	
	PROCEDURE renderPion(x,y : INTEGER; pion : pion);
	BEGIN
		plot(FOR_TAB[pion.forme,1],     x, y, COL_WHITE, pion.couleur);
		plot(FOR_TAB[pion.forme,2], x + 1, y, COL_WHITE, pion.couleur);
	END;
	
	// fais le rendu de la grille de jeu dans sa globalité
	PROCEDURE renderGame(g : grille);
	VAR
		pionTest : pion;
		i,j : INTEGER;
	BEGIN
		Randomize;
		pionTest.forme := FORME_ROND - 1;
		
		renderText('Qwirkle par Cyril et Paul :', 1, 1, COL_WHITE,COL_BLACK);
		
		renderLine(51,1,51, HEIGHT - 2, 7, 0);
		renderLine(0,2,51,2, 7, 0);
		plot('+',51,0,7,0);
		plot('+',51,HEIGHT - 1,7,0);
		plot('+',0,2,7,0);
		plot('+',51,2,7,0);
		
		renderText('*-* SCORES *-*', 62, 1, COL_WHITE, COL_BLACK);
		renderText('JOUEUR 1:', 53, 3, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 54, 5, COL_RED, COL_WHITE);
		
		renderText('JOUEUR 2:', 77, 3, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 78, 5, COL_LBLUE, COL_WHITE);
		renderLine(52 ,HEIGHT DIV 2 - 7, WIDTH - 2, HEIGHT DIV 2 - 7, COL_WHITE, COL_BLACK);
		renderText('*-* HISTORIQUE *-*', 60, HEIGHT DIV 2 - 6, COL_WHITE, COL_BLACK);
		
		// Fais le rendu de l'historique
		FOR i := 0 TO 16 DO
		BEGIN
			renderText('MOV ' + inttostr(i), 53, HEIGHT DIV 2 - 4 + i, COL_WHITE, COL_BLACK );
			IF i MOD 2 = 0 THEN
				renderText('J1', 60, HEIGHT DIV 2 - 4 + i, COL_LBLUE, COL_WHITE)
			ELSE
				renderText('J2', 60, HEIGHT DIV 2 - 4 + i, COL_RED, COL_WHITE);
			pionTest.forme   := random(5);
			pionTest.couleur := random(6) + 1;
			renderPion(64, HEIGHT DIV 2 - 4 + i, pionTest);
			renderText('x: ' + inttostr(random(24) + 1), 67, HEIGHT DIV 2 - 4 + i, COL_GREEN, COL_BLACK);
			renderText(', y: ' + inttostr(random(24) + 1), 73, HEIGHT DIV 2 - 4 + i, COL_GREEN, COL_BLACK);
			
		END;
		
		FOR i := 0 TO 24 DO
		BEGIN
			FOR j := 0 TO 24 DO
			BEGIN
				renderPionInGrille(i + 1, j + 1, g[i,j]);
			END;
		END;
		
		render;
	END;
	
	// efface l'écran en appliquant la couleur bgColor à tout l'écran.
	PROCEDURE clearScreen (bgColor :  BYTE);
	VAR
		x,y : INTEGER;
	BEGIN
		FOR x := 0 TO WIDTH - 1 DO
		BEGIN
			FOR y := 0 TO HEIGHT - 1 DO
			BEGIN
				globalScreen[x,y].tCol  := 7;
				globalScreen[x,y].bgCol := bgColor;
				globalScreen[x,y].chr   := ' ';
			END;
		END;
	END;
END.
