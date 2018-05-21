UNIT console;
INTERFACE

USES constants  in 'core/constants.pas', crt,
	 structures in 'core/structures.pas';

TYPE
	point = RECORD
		x,y : INTEGER;
	END;
	
	rRectangle = ARRAY [0..4 - 1] OF point;
	
	FUNCTION  requestMunuRender : INTEGER;
	PROCEDURE render;
	PROCEDURE clearScreen;

IMPLEMENTATION
	VAR
		// Surface principale
		globalScreen : ARRAY [0..WIDTH - 1, 0..HEIGHT - 1] OF CHAR;
	
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
				write(globalScreen[x,y]);
			END;
			writeln;
		END;
	END;
	
	// Créer les bordures du menu. Fait le rendu dans la surface globalScreen
	PROCEDURE renderMenuBorder();
	VAR
		x : INTEGER;
	BEGIN
		// Barres du haut et du bas
		FOR x := 1 TO WIDTH - 2 DO 
		BEGIN
			globalScreen[x,          0] := '-';
			globalScreen[x, HEIGHT - 1] := '-';
		END;
		
		// Barres sur les côtés
		FOR x := 1 TO HEIGHT - 2 DO
		BEGIN
			globalScreen[0         , x] := '|';
			globalScreen[WIDTH - 1 , x] := '|';
		END;
		
		globalScreen[0         ,          0] := '+';
		globalScreen[0         , HEIGHT - 1] := '+';
		globalScreen[WIDTH - 1 ,          0] := '+';
		globalScreen[WIDTH - 1 , HEIGHT - 1] := '+';
	END;
	
	PROCEDURE renderText(text : STRING; x,y : INTEGER);
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 1 TO length(text) DO
			globalScreen[i + x, y] := text[i];
	END;
	
	PROCEDURE renderCursor(posCursor, x, y : INTEGER);
	VAR
		i,j : INTEGER;
	BEGIN
		FOR i := x TO x + 1 DO
		BEGIN
			FOR j := y TO y + 2 DO
			BEGIN
				globalScreen[i,j] := ' ';
			END;
		END; 
		globalScreen[x    ,y + posCursor] := '-';
		globalScreen[x + 1,y + posCursor] := '>';
	END;
	
	// Fais le rendu du menu. Retourne le choix.
	FUNCTION requestMunuRender() : INTEGER;
	VAR
		ch : CHAR;
		cursor : INTEGER;
	BEGIN
		renderText('Bienvenus dans Qwirkle', 3,3);
		renderText('developpé par Paul Planchon et Cyril Marzook', 3,4);
		renderText('Veuillez vous déplacer avec UP / DOWN / RIGHT', 3,6);
		
		cursor := 0;
		
		renderText('TEST1', 6,8);
		renderText('TEST2', 6,9);
		renderText('TEST3', 6,10);
		
		render;
		
		REPEAT
			
			ch := ReadKey;
			CASE ch OF
				#80: inc(cursor);
				#72: dec(cursor);
			END;
			IF cursor > 2 THEN cursor := 2;
			IF cursor < 0 THEN cursor := 0;
			
			renderCursor(cursor, 3, 8);
			writeln(cursor);
			clrscr;
			render;
		UNTIL ch = #77;
		
		requestMunuRender := cursor;
	END;
	
	PROCEDURE clearScreen;
	VAR
		x,y : INTEGER;
	BEGIN
		FOR x := 0 TO WIDTH - 1 DO
		BEGIN
			FOR y := 0 TO HEIGHT - 1 DO
			BEGIN
				globalScreen[x,y] := ' ';
			END;
		END;
	END;
END.
