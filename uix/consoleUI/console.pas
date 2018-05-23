UNIT console;
INTERFACE

USES constants  in 'core/constants.pas', crt,
	 structures in 'core/structures.pas';

TYPE
	point = RECORD
		x,y : INTEGER;
	END;
	
	printable = RECORD
		chr   : CHAR;
		tCol  : BYTE;
		bgCol : BYTE;
	END;
	
	rRectangle = ARRAY [0..4 - 1] OF point;
	
	PROCEDURE render;
	PROCEDURE renderGame;
	PROCEDURE renderMenuBorder();
	PROCEDURE clearScreen (bgColor :  BYTE);

IMPLEMENTATION
	VAR
		// Surface principale
		globalScreen : ARRAY [0..WIDTH - 1, 0..HEIGHT - 1] OF printable;
	
	// Fait le rendu à la console. Utilise la surface screen pour faire
	// le rendu.
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
	
	FUNCTION isInScreen(x,y : INTEGER) : BOOLEAN;
	BEGIN
		isInScreen := NOT((x < 0) or (x > WIDTH) or (y < 0) or (y > HEIGHT));
	END;
	
	PROCEDURE plot(chr : CHAR; x,y,tCol,bgCol : INTEGER);
	BEGIN
		writeln(isInScreen(x,y));
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
	
	PROCEDURE renderPion(x,y : INTEGER; pion : pion);
	BEGIN
		plot(COL_FOR[pion.forme,1], x, y, COL_WHITE, pion.couleur);
		plot(COL_FOR[pion.forme,2], x + 1, y, COL_WHITE, pion.couleur);
	END;
	
	PROCEDURE renderGame();
	VAR
		pionTest : pion;
	BEGIN
		pionTest.forme := FORME_ROND - 1;
		pionTest.couleur := COL_RED;
		renderText('Qwirkle :', 1, 1, COL_YELLOW,COL_RED);
		renderLine(51,1,51, HEIGHT - 2, 7, 0);
		renderLine(0,2,51,2, 7, 0);
		plot('+',51,0,7,0);
		plot('+',51,HEIGHT - 1,7,0);
		plot('+',0,2,7,0);
		plot('+',51,2,7,0);
		renderPion(5,5,pionTest);
	END;
	
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
