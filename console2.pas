UNIT console2;

INTERFACE
USES constants, crt, structures, sysutils, game;
	
PROCEDURE renderGrille(g : grille);
PROCEDURE renderMain(main : tabPion);
PROCEDURE initConsole(g : grille);
FUNCTION mainSelector(main : tabPion) : pion;
FUNCTION posSelector(g : grille) : position;
FUNCTION multiplePionSelector(g : grille; main : tabPion) : tabPion;

IMPLEMENTATION
VAR
	tailleGrille, selector : INTEGER;

	PROCEDURE initConsole(g : grille);
	BEGIN
		tailleGrille := length(g);
		selector := 1;
	END;

	PROCEDURE renderLigne(taille : INTEGER);
	VAR
		i : INTEGER;
	BEGIN
		write('+');
		FOR i := 1 TO taille - 1 DO
		BEGIN
			write('-');
		END;
		writeln('+');
	END;

	PROCEDURE renderPion(p : pion);
	BEGIN
		TextColor(p.couleur);
		write(FOR_TAB[p.forme][1]);
		write(FOR_TAB[p.forme][2]);
		TextColor(7);
	END;

	PROCEDURE renderLigneNumero(taille : INTEGER);
	VAR
		i : INTEGER;
	BEGIN
		write('|  ');
		FOR i := 0 TO taille - 1 DO
		BEGIN
			IF i DIV 10 = 0 THEN
			BEGIN
				TextBackground(i MOD 7);
				write(i, ' ');
			END
			ELSE
			BEGIN
				TextBackground(i MOD 7);
				write(i);
			END; 
		END;
		TextBackground(0);
		write('|');
		writeln;
	END;

	// fais le rendu de la grille dans un carré avec des bordures et des chiffres
	PROCEDURE renderGrille(g : grille);
	VAR
		i, j : INTEGER;
	BEGIN
		tailleGrille := length(g);
		renderLigne(length(g) * 2 + 3);
		renderLigneNumero(length(g));
		FOR i := 0 TO length(g) - 1 DO
		BEGIN
			write('|');
			TextBackground(i MOD 7);
			IF i DIV 10 = 0 THEN
				write(i, ' ')
			ELSE
				write(i);
			TextBackground(0);
			FOR j := 0 TO length(g) - 1 DO
			BEGIN
				renderPion(g[j, i]);
			END;
			writeln('|');
		END;
		renderLigne(length(g) * 2 + 3);
	END;

	PROCEDURE renderPionInMain(main : tabPion);
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			renderPion(main[i]);
		END;
	END;
	
	PROCEDURE renderTextWithBordure(text : STRING; taille : INTEGER);
	VAR
		i : INTEGER;
	BEGIN
		write('|');
		FOR i := 0 TO taille - 2 DO
		BEGIN
			IF (i < length(text)) AND (i > 0) THEN
				write(text[i])
			ELSE
				write(' ');
		END;
		writeln('|');
	END;
	
	PROCEDURE renderMainNoLigneAfter(text : STRING; main : tabPion);
	VAR
		i : INTEGER;
	BEGIN
		renderLigne(tailleGrille * 2 + 3);
		renderTextWithBordure(text, tailleGrille * 2 + 3);
		
		write('|  ');
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			renderPion(main[i]);
		END;
		FOR i := 0 TO tailleGrille * 2 + 3 - (length(main)) * 2 - 4 DO write(' ');

		writeln('|');
	END;
	
	FUNCTION mainSelector(main : tabPion) : pion;
	VAR
		i : INTEGER;
		ch : CHAR;
		hasChoosePionToPlay : BOOLEAN;
	BEGIN
		hasChoosePionToPlay := False;
		renderMainNoLigneAfter('Choissisez votre pion : ', main);
		
		write('|');
		FOR i := 0 TO selector * 2  - 1 DO write(' ');
		renderPion(PION_FLECHE);
		FOR i := 0 TO tailleGrille * 2 + 3 - (selector * 2 + 4) DO write(' ');
		writeln('|');
		
		renderLigne(tailleGrille * 2 + 3);
		
		ch := readkey();
		CASE ch OF
			#77 : IF selector < length(main) THEN inc(selector);
			#75 : IF selector > 1 THEN dec(selector);
			'f' : hasChoosePionToPlay := True;
		END;
		
		IF hasChoosePionToPlay THEN
			mainSelector := main[selector]
		ELSE
			mainSelector := PION_NULL;
	END;

	PROCEDURE renderMain(main : tabPion);
	BEGIN
		renderMainNoLigneAfter('Vos pions :', main);
		renderLigne(tailleGrille * 2 + 3);
	END;

	FUNCTION copyGrille(a : grille) : grille;
	VAR
		i, j : INTEGER;
		newGrille : grille;
	BEGIN
		setLength(newGrille, length(a), length(a));
		FOR i := 0 TO length(a) - 1 DO
		BEGIN
			FOR j := 0 TO length(a) - 1 DO
			BEGIN
				newGrille[i, j] := a[i, j];
			END;
		END;
		
		copyGrille := newGrille;
	END;

	FUNCTION posSelector(g : grille) : position;
	VAR
		posX, posY : INTEGER;
		hasChoosenAPosToPlay : BOOLEAN;
		lastGrille : grille;
		ch : CHAR;
	BEGIN
		lastGrille := copyGrille(g);
		hasChoosenAPosToPlay := False;
		posX := tailleGrille DIV 2;
		posY := tailleGrille DIV 2;
		
		REPEAT
			g := copyGrille(lastGrille);
			clrscr;
			g[posX, posY] := PION_ROUGE;
			renderGrille(g);
			
			ch := readkey();
			writeln(ord(ch));
			case ch of
				#72 : IF (posY - 1 >= 0) THEN dec(posY);
				#75 : IF (posX - 1 >= 0) THEN dec(posX);
				#77 : IF (posX + 1 < tailleGrille) THEN inc(posX);
				#80 : IF (posY + 1 < tailleGrille) THEN inc(posY);
				'f' : hasChoosenAPosToPlay := true;
			END;
		UNTIL hasChoosenAPosToPlay;
		
		posSelector.x := posX;
		posSelector.y := posY;
	END;

	FUNCTION multiplePionSelector(g : grille; main : tabPion) : tabPion;
	VAR
		i : INTEGER;
		ch : CHAR;
		pionChoisis : ARRAY [0..6] OF BOOLEAN;
		hasChoose, hasFinished : BOOLEAN;
		finalTab : tabPion;
	BEGIN
		FOR i := 0 TO 5 DO pionChoisis[i] := FALSE;
		
		selector := 1;
		
		REPEAT
			renderGrille(g);
		
			hasFinished := False;
			hasChoose   := False;
			renderMainNoLigneAfter('Choissisez pion a echanger : ', main);
			
			write('|');
			FOR i := 0 TO (tailleGrille) DO
			BEGIN
				IF (i > 0) AND (i < (length(pionChoisis))) AND pionChoisis[i] THEN
				BEGIN
					renderPion(PION_ROUGE);
				END
				ELSE
					IF selector = i THEN
						renderPion(PION_FLECHE)
					ELSE
						write('  ');
			END;
			writeln('|');
			
			renderLigne(tailleGrille * 2 + 3);
			ch := readkey();
			CASE ch OF
				#77 : IF selector < 6 THEN inc(selector);
				#75 : IF selector > 1 THEN dec(selector);			
				#13 : hasChoose   := True;
				'f' : hasFinished := True;
			END;
			
			IF hasChoose THEN
				pionChoisis[selector] := NOT pionChoisis[selector];
		UNTIL hasFinished;
		
		setLength(finalTab, 0);
		
		FOR i := 1 TO 6 DO
		BEGIN
			IF pionChoisis[i] THEN
			BEGIN
				setLength(finalTab, length(finalTab) + 1);
				finalTab[length(finalTab) - 1] := main[i - 1];
			END;
		END;
		
		multiplePionSelector := finalTab;
	END;

END.
