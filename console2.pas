UNIT console2;

INTERFACE
USES constants, crt, structures, sysutils, game;
	
PROCEDURE renderGrille(g : grille);
PROCEDURE renderMain(main : tabPion);
PROCEDURE initConsole(g : grille);
PROCEDURE renderScore (joueur : tabJoueur);
PROCEDURE renderTextWithBordure(text : STRING);
PROCEDURE renderTextWillFullBordure(text : STRING);

FUNCTION renderPopUpWithResponce(text : STRING) : CHAR;
FUNCTION mainSelector(g : grille; main : tabPion) : pion;
FUNCTION posSelector(g : grille; main : tabPion) : position;
FUNCTION multiplePionSelector(g : grille; main : tabPion) : tabPion;


IMPLEMENTATION
VAR
	tailleGrille, selector : INTEGER;
	
	
	
	// on initialise la grille avec le selector
	PROCEDURE initConsole(g : grille); 
	BEGIN
		tailleGrille := length(g);
		selector := 1;
	END;
	
	
	// ici on met la grille a l'interieur d'un cadrillage 
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
	
	// on affiche le pion a partir des constantes qui correspondent aux formes et couleurs
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
	
	// on affiche la main en dessous de la grille 
	PROCEDURE renderPionInMain(main : tabPion);
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			renderPion(main[i]);
		END;
	END;
	
	// avec cette procedure on affiche les differents text a l'interieur du cadrillage
	PROCEDURE renderTextWithBordure(text : STRING);
	VAR
		i : INTEGER;
	BEGIN
		write('|');
		FOR i := 0 TO tailleGrille * 2 + 3 - 2 DO
		BEGIN
			IF (i < length(text) + 1) AND (i > 0) THEN
				write(text[i])
			ELSE
				write(' ');
		END;
		writeln('|');
	END;
	
	
	PROCEDURE renderTextWillFullBordure(text : STRING);
	BEGIN
		renderLigne(tailleGrille * 2 + 3);
		renderTextWithBordure(text);
		renderLigne(tailleGrille * 2 + 3);
	END;
	
	// affiche la main 
	PROCEDURE renderMainNoLigneAfter(text : STRING; main : tabPion);
	VAR
		i : INTEGER;
	BEGIN
		renderLigne(tailleGrille * 2 + 3);
		renderTextWithBordure(text);
		
		write('|  ');
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			renderPion(main[i]);
		END;
		FOR i := 0 TO tailleGrille * 2 + 3 - (length(main)) * 2 - 4 DO write(' ');

		writeln('|');
	END;
	
	// fonction qui permet de choisir un pion dans la main a l'aide des touches du claviers
	FUNCTION mainSelector(g : grille; main : tabPion) : pion;
	VAR
		i : INTEGER;
		ch : CHAR;
		hasChoosePionToPlay : BOOLEAN;
	BEGIN
		REPEAT
			clrscr;
			renderGrille(g);
			hasChoosePionToPlay := False;
			renderTextWithBordure('Choissisez votre pion : ');
			renderMainNoLigneAfter('F pour choisir', main);
			
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
				mainSelector := main[selector - 1]
			ELSE
				mainSelector := PION_NULL;
		UNTIL hasChoosePionToPlay;
	END;

	PROCEDURE renderMain(main : tabPion);
	BEGIN
		renderMainNoLigneAfter('Vos pions :', main);
		renderLigne(tailleGrille * 2 + 3);
	END;

	//fonction qui permet de prendre la position du selector dans la grille pour placer le pion 
	FUNCTION posSelector(g : grille; main : tabPion) : position;
	VAR
		posX, posY : INTEGER;
		hasChoosenAPosToPlay : BOOLEAN;
		lastGrille, lastGrille2 : grille;
		ch : CHAR;
	BEGIN
		lastGrille := copyGrille(g);
		lastGrille2 := copyGrille(g);
		hasChoosenAPosToPlay := False;
		posX := tailleGrille DIV 2;
		posY := tailleGrille DIV 2;
		
		REPEAT
			lastGrille := copyGrille(lastGrille2);
			clrscr;
			lastGrille[posX, posY] := PION_ROUGE;
			renderGrille(lastGrille);
			renderTextWillFullBordure('fleche pour deplacement, F finir');
			renderMain(main);
			
			ch := readkey();
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
		setLength(lastGrille, 0, 0);
		setLength(lastGrille2, 0, 0);
	END;

	// fonction qui permet de selectionner plusieurs pions dans la main pour les echanger 
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
			clrscr;
			renderGrille(g);
		
			hasFinished := False;
			hasChoose   := False;
			renderTextWithBordure('Choissisez pion a echanger : ');
			renderMainNoLigneAfter('ENTER pour choisir, F pour finir', main);
			
			write('|');
			FOR i := 0 TO (tailleGrille) DO
			BEGIN
				IF selector = i THEN
				BEGIN
					renderPion(PION_FLECHE);
				END
				ELSE
					IF (i > 0) AND (i < (length(pionChoisis))) AND pionChoisis[i] THEN
						renderPion(PION_ROUGE)
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
	
	// fonction qui affiche le nombre de point des joueurs a gauche de la grille 
	PROCEDURE renderLigneScore(joueur : tabJoueur; a,b : INTEGER);
	VAR
		i : INTEGER;
		score : STRING;
	BEGIN
		write('|');
		IF a <> b THEN
		BEGIN
			IF joueur[a].genre THEN
				score := ' Joueur n°' + inttostr(a) + ': ' + inttostr(joueur[a].score)
			ELSE
				score := ' Ordin. n°' + inttostr(a) + ': ' + inttostr(joueur[a].score);
			
			write(score);
			
			FOR i := 0 TO (tailleGrille * 2 + 3) DIV 2 - length(score) DO write(' ');
			
			IF joueur[b].genre THEN
				score := ' Joueur n°' + inttostr(b) + ': ' + inttostr(joueur[b].score)
			ELSE
				score := ' Ordin. n°' + inttostr(b) + ': ' + inttostr(joueur[b].score);
			
			write(score);
			
			FOR i := 0 TO (tailleGrille * 2 + 3) DIV 2 - length(score) DO write(' ');
		END
		ELSE
		BEGIN
			IF joueur[a].genre THEN
				score := ' Joueur n°' + inttostr(a) + ': ' + inttostr(joueur[a].score)
			ELSE
				score := ' Ordin. n°' + inttostr(a) + ': ' + inttostr(joueur[a].score);
			
			write(score);
			
			FOR i := 0 TO (tailleGrille * 2 + 3) - length(score) - 1 DO write(' ');
		END;
		
		writeln('|');
	END;
	
	// permet d'afficher du texte par dessus la grille 
	FUNCTION renderPopUpWithResponce(text : STRING) : CHAR;
	BEGIN
		renderLigne(tailleGrille * 2 + 3);
		renderTextWithBordure(text);
		renderLigne(tailleGrille * 2 + 3);
		renderPopUpWithResponce := readkey;
	END;
	
	PROCEDURE renderScore (joueur : tabJoueur);
	VAR
		i : INTEGER;
	BEGIN
		renderLigne(tailleGrille * 2 + 3);
		
		CASE length(joueur) OF
			1 : renderLigneScore(joueur, 0, 0);
			2 : renderLigneScore(joueur, 0, 1);
			ELSE
			BEGIN
				IF length(joueur) MOD 2 = 0 THEN
				BEGIN
					FOR i := 0 TO length(joueur) DIV 2 - 1 DO
					BEGIN
						renderLigneScore(joueur, i * 2, i * 2 + 1);
					END;
				END
				ELSE
				BEGIN
					FOR i := 0 TO length(joueur) DIV 2 - 1 DO
					BEGIN
						renderLigneScore(joueur, i * 2, i * 2 + 1);
					END;
					renderLigneScore(joueur, length(joueur), length(joueur));
				END;
			END;
		END;
		
		renderLigne(tailleGrille * 2 + 3);
	END;
END.
