{
* 	CETTE UNIT EST RESPONSABLE DE TOUT L'AFFICHAGE CONSOLE.
*   C'EST ELLE QUI GERE TOUT L'ECRAN DE LA CONSOLE.
*   ELLE NE GERE PAS LES INPUTS OU LE MOTEUR DU JEU.
*   ELLE NE FAIT QUE LE RENDU
* }

UNIT console;
INTERFACE

USES constants  in 'core/constants.pas', crt,
	structures in 'core/structures.pas',
	 sysutils;

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
PROCEDURE addToHistorique(p : pion; x, y : INTEGER; joueur : STRING);
PROCEDURE initConsole;
PROCEDURE renderPion(x,y : INTEGER; pion : pion);
PROCEDURE renderNumber(x1, y1, x2, y2 : INTEGER);
FUNCTION  selectorPos(g : grille) : position;
FUNCTION  selectorMain(main : mainJoueur) : pion;

IMPLEMENTATION
	VAR
		// Surface principale
		globalScreen : ARRAY [0..WIDTH - 1, 0..HEIGHT - 1] OF printable;
		historique   : ARRAY [0..12] OF dataHistorique;
		historiqueIndex : INTEGER;

	PROCEDURE initConsole;
	VAR
		i : INTEGER;
	BEGIN
		historiqueIndex := 0;
		FOR i := 0 TO length(historique) - 1 DO
		BEGIN
			historique[i].id := -1;
		END;
	END;

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
		renderLine(        0,      0, WIDTH - 1,      0, 7, 0);
		renderLine(        0,      0,         0, HEIGHT - 1, 7, 0);
		renderLine(        0, HEIGHT - 1, WIDTH - 1, HEIGHT - 1, 7, 0);
		renderLine(WIDTH - 1,      0, WIDTH - 1, HEIGHT - 1, 7, 0);

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

	PROCEDURE renderMain(x,y : INTEGER ; main : mainJoueur);
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			renderPion(x+i*2,y,main[i]);
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
		plot(FOR_TAB[pion.forme,1],     x, y, COL_WHITE, COL_TAB[pion.couleur]);
		plot(FOR_TAB[pion.forme,2], x + 1, y, COL_WHITE, COL_TAB[pion.couleur]);
	END;

	PROCEDURE renderNodeHistorique(node : dataHistorique; i : INTEGER);
	BEGIN
		IF node.id >= 0 THEN
		BEGIN
			renderText('MOV ' + inttostr(node.id), 55, HEIGHT DIV 2 - 1 + i, COL_WHITE, COL_BLACK );
			CASE node.joueur OF
				'J1' : renderText(node.joueur, 62, HEIGHT DIV 2 - 1 + i, COL_LBLUE, COL_WHITE);
				'J2' : renderText(node.joueur, 62, HEIGHT DIV 2 - 1 + i, COL_LBLUE, COL_RED);
				ELSE renderText(node.joueur, 62, HEIGHT DIV 2 - 1 + i, COL_LBLUE, COL_WHITE);
			END;
			renderPion(65, HEIGHT DIV 2 - 1 + i, node.pion);
			renderText('x: ' + inttostr(node.posX), 69, HEIGHT DIV 2 - 1 + i, COL_GREEN, COL_BLACK);
			renderText(', y: ' + inttostr(node.posY), 75, HEIGHT DIV 2 - 1 + i, COL_GREEN, COL_BLACK);
		END;
	END;

	FUNCTION selectorPos(g: grille) : position;
	VAR
		i,j : INTEGER;
		ch  : char;
		hasPlaced : boolean;
		p  : pion;
		last : grille;
		pos : position;
	BEGIN
		last := g;
		p.couleur := COULEUR_ROUGE;
		p.forme := FORME_NULL;
		hasPlaced := false;
		i := 2;
		j := 2;
		clrscr;
		renderPionInGrille(i, j, p);
		render;
		REPEAT
			renderPionInGrille(i, j, last[i - 2,j - 2]);
			ch := readkey();
			case ch of
				#77 : IF (i+1 < 27) THEN inc(i);
				#75 : IF (i-1 > 1)  THEN dec(i);
				#72 : IF (j-1 > 1)  THEN dec(j);
				#80 : IF (j+1 < 27) THEN inc(j);
				#13 : hasPlaced := true;
			END;
			clrscr;
			renderPionInGrille(i, j, p);
			render;
		UNTIL (hasPlaced);
		IF hasPlaced THEN
		BEGIN
			pos.x := i;
			pos.y := j;
			selectorPos := pos;
		END;
	END;

	FUNCTION selectorMain(main : mainJoueur) : pion;
	VAR
		hasPlaced, swapPion : BOOLEAN;
		ch        : char;
		p         : pion;
		i         : INTEGER;
	BEGIN
		i := 0;
		clrscr;
		renderMain(3, HEIGHT - 3, main);
		plot('/', 3, HEIGHT - 2, 7, 0);
		plot('\',  4,HEIGHT - 2, 7, 0);
		render;
		hasPlaced := False;
		swapPion := False;
		p.couleur := COULEUR_NULL;
		p.forme := FORME_NULL;
		REPEAT
			ch := readKey();
			plot(' ', 3 + i * 2, HEIGHT - 2, 7, 0);
			plot(' ',  3 + i * 2 + 1,HEIGHT - 2, 7, 0);
			CASE ch OF
				#77 : IF i < length(main) - 1 THEN inc(i);
				#75 : IF i > 0 THEN dec(i);
				#13 : hasPlaced := True;
				#114 : swapPion := True;
			END;
			clrscr;
			plot('/', 3 + i * 2, HEIGHT - 2, 7, 0);
			plot('\',  3 + i * 2 + 1,HEIGHT - 2, 7, 0);
			clrscr;
			render;
			writeln(i);
		UNTIL hasPlaced or swapPion;
		IF hasPlaced THEN
			selectorMain := main[i];
		IF swapPion THEN
			selectorMain := p;
	END;

	PROCEDURE renderHistorique;
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO 14 DO
		BEGIN
			renderNodeHistorique(historique[(historiqueIndex + i) MOD 12], i + 4);
		END;
	END;

	PROCEDURE renderNumber(x1, y1, x2, y2 : INTEGER);
	VAR
		x : INTEGER;
	BEGIN
		// ligne horizontale
		IF (x1 <> x2) and (y1 = y2) THEN
		BEGIN
			FOR x := x1 TO x2 DO
			BEGIN
				IF x - x1 > 9 THEN
				BEGIN
					globalScreen[x*2 - 1, y1].chr     := inttostr(x - x1)[1];
					globalScreen[x*2 , y1].chr := inttostr(x - x1)[2];
					globalScreen[x*2 - 1, y1].tCol     := x MOD 6 +1;
					globalScreen[x*2 - 1, y1].bgCol    := COULEUR_NULL;
					globalScreen[x*2, y1].tCol     := x MOD 6 +1;
					globalScreen[x*2, y1].bgCol    := COULEUR_NULL;
				END
				ELSE
					globalScreen[x*2-1, y1].chr := inttostr(x - x1)[1];
					globalScreen[x*2-1, y1].tCol     := x MOD 6 +1;
					globalScreen[x*2-1, y1].bgCol    := COULEUR_NULL;
			END;
		END;

		// ligne verticale
		IF (x1 = x2) and (y1 <> y2) THEN
		BEGIN
			FOR x := y1 TO y2 DO
			BEGIN
				IF x - y1 > 9 THEN
				BEGIN
					globalScreen[x1, x].chr   := inttostr(x - y1)[1];
					globalScreen[x1, x].tCol  := x MOD 6 + 1;
					globalScreen[x1, x].bgCol := COULEUR_NULL;
					globalScreen[x1 + 1, x].chr   := inttostr(x - y1)[2];
					globalScreen[x1 + 1, x].tCol  := x MOD 6 + 1;
					globalScreen[x1 + 1, x].bgCol := COULEUR_NULL;
				END
				ELSE
				BEGIN
					globalScreen[x1, x].chr   := inttostr(x - y1)[1];
					globalScreen[x1, x].tCol  := x MOD 6 + 1;
					globalScreen[x1, x].bgCol := COULEUR_NULL;
				END;
			END;
		END;
	END;


	// fais le rendu de la grille de jeu dans sa globalité
	PROCEDURE renderGame(g : grille);
	VAR
		pionTest: pion;
		i,j : INTEGER;
	BEGIN
		pionTest.forme := FORME_ROND - 1;

		renderText('Qwirkle par Cyril et Paul :', 1, 1, COL_WHITE,COL_BLACK);

		renderLine(53,1,53, HEIGHT - 2, 7, 0);
		renderLine(0,2,53,2, 7, 0);
		renderLine(53 , 11, WIDTH - 2, 11, COL_WHITE, COL_BLACK);
		renderLine(0 , HEIGHT - 5, 53, HEIGHT - 5, COL_WHITE, COL_BLACK);
		plot('+', 53, HEIGHT - 5, 7, 0);
		plot('+', 0, HEIGHT - 5, 7, 0);
		plot('+', 53, 11, 7, 0);
		plot('+', WIDTH - 1, 11, 7, 0);
		plot('+',53,0,7,0);
		plot('+',53,HEIGHT - 1,7,0);
		plot('+',0,2,7,0);
		plot('+',53,2,7,0);
		renderText('*-* SCORES *-*', 64, 1, COL_WHITE, COL_BLACK);
		renderText('JOUEUR 1:', 55, 3, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 56, 5, COL_RED, COL_WHITE);

		renderText('JOUEUR 2:', 79, 3, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 80, 5, COL_LBLUE, COL_WHITE);

		renderText('JOUEUR 3:', 55, 7, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 56, 9, COL_GREEN, COL_WHITE);

		renderText('JOUEUR 4:', 79, 7, COL_WHITE, COL_BLACK);
		renderText(' 999 ', 80, 9, COL_MAGENTA, COL_WHITE);
		renderText('Votre main :', 2, HEIGHT - 4, COL_WHITE, COL_BLACK);
		//mainTest := creerMain
		//afficheMain(61,10,mainTest);
		renderNumber(2,3, 26, 3);
		renderNumber(1,4, 1, 28);


		renderText('*-* HISTORIQUE *-*', 63,  12, COL_WHITE, COL_BLACK);

		renderHistorique;

		FOR i := 0 TO 24 DO
		BEGIN
			FOR j := 0 TO 24 DO
			BEGIN
				renderPionInGrille(i + 2, j + 2, g[i,j]);
			END;
		END;

		render;
	END;


	PROCEDURE addToHistorique(p : pion; x, y : INTEGER; joueur : STRING);
	BEGIN
		historique[historiqueIndex MOD 12].pion   := p;
		historique[historiqueIndex MOD 12].posX   := x;
		historique[historiqueIndex MOD 12].posY   := y;
		historique[historiqueIndex MOD 12].id     := historiqueIndex;
		historique[historiqueIndex MOD 12].joueur := joueur;
		inc(historiqueIndex);
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
