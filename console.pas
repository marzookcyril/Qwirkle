{
* 	CETTE UNIT EST RESPONSABLE DE TOUT LAFFICHAGE CONSOLE.
*   CEST ELLE QUI GERE TOUT LECRAN DE LA CONSOLE.
*   ELLE NE GERE PAS LES INPUTS OU LE MOTEUR DU JEU.
*   ELLE NE FAIT QUE LE RENDU
* }

UNIT console;
INTERFACE

USES constants, crt, structures, sysutils;

TYPE
	// type primitif de tout ce qui peut être affiché à lécran.
	printable = RECORD
		chr   : CHAR;
		tCol  : BYTE;
		bgCol : BYTE;
	END;

PROCEDURE render;
PROCEDURE initConsole;
PROCEDURE renderMenuBorder(g : grille);
PROCEDURE renderScore(joueur, score : INTEGER);
PROCEDURE renderHistorique;
PROCEDURE renderGame(g : grille);
PROCEDURE renderMain(x,y, joueur : INTEGER ; main : tabPion);
PROCEDURE renderPopUp(text : STRING);
PROCEDURE renderTitle(title : STRING);
PROCEDURE renderText(text : STRING; x, y, tCol, bgCol : INTEGER);
PROCEDURE renderPionInGrille(x,y : INTEGER; pion : pion);
PROCEDURE renderJoueurText(nbrJoueurHumain, nbrJoueurMachine : INTEGER);
PROCEDURE addToHistorique(p : pion; x, y : INTEGER; joueur : STRING);
FUNCTION renderPopUpWithResponce(text : STRING) : CHAR;
FUNCTION selectorMain(main : tabPion; joueur : INTEGER) : pion;
FUNCTION selectorPos(g: grille; x, y : INTEGER) : position;
FUNCTION remplacerMain(main : tabPion; joueur : INTEGER) : tabPion;
FUNCTION getHeight : INTEGER;
PROCEDURE calculBordure(g : grille);

IMPLEMENTATION
	VAR
		// Surface principale
		WIDTH, HEIGHT, tailleMenu : INTEGER;
		globalScreen : ARRAY OF ARRAY OF printable;
		lastglobalScreen : ARRAY OF ARRAY OF printable;
		historique   : ARRAY [0..18] OF dataHistorique;
		historiqueIndex : INTEGER;
		isInPopUp : BOOLEAN;
		
		
		// separation en grille et autre
		xSeparation, ySeparation : INTEGER;

	// efface lécran en appliquant la couleur bgColor à tout lécran.
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
	
	FUNCTION abs(n : INTEGER) : INTEGER;
	BEGIN
		IF n < 0 THEN
			abs := -n
		ELSE
			abs := n;
	END;
	
	FUNCTION min(a, b :INTEGER) : INTEGER;
	BEGIN
		IF a > b THEN
			min := b
		ELSE
			min := a;
	END;
	
	FUNCTION max(a, b :INTEGER) : INTEGER;
	BEGIN
		IF a < b THEN
			max := b
		ELSE
			max := a;
	END;
	
	PROCEDURE calculBordure(g : grille);
	BEGIN
		xSeparation := length(g) DIV 2;
		HEIGHT := 2 * xSeparation + 9;
		WIDTH := 2 * xSeparation + 2 * 30;
	END;
	
	FUNCTION getHeight : INTEGER;
	BEGIN
		getHeight := HEIGHT;
	END;
	
	FUNCTION getWidth : INTEGER;
	BEGIN
		getWidth := WIDTH;
	END;
	
	// retourne le pion de la vraie grille dans le referentielle de la grille d'affichage
	FUNCTION getPion(g : grille; x,y : INTEGER) : pion;
	BEGIN
		getPion := g[(TAILLE_GRILLE DIV 2) - xSeparation + x, (TAILLE_GRILLE DIV 2) - xSeparation + y];
	END;


	PROCEDURE initConsole;
	VAR
		i : INTEGER;
	BEGIN
		WIDTH := 90;
		HEIGHT := 45;
		setLength(globalScreen,WIDTH,HEIGHT);
		isInPopUp := False;
		historiqueIndex := 0;
		FOR i := 0 TO length(historique) - 1 DO
		BEGIN
			historique[i].id := -1;
		END;
		clearScreen(0);
	END;

	// Affiche à lécran le contenue de la surface générale (chez nous globalScreen)
	// en prenant en compte les couleurs et le BG.
	PROCEDURE render;
	VAR
		x,y : INTEGER;
	BEGIN
		clrscr;
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

	FUNCTION isInScreen(x,y : INTEGER) : BOOLEAN;
	BEGIN
		isInScreen := NOT((x < 0) or (x > WIDTH) or (y < 0) or (y > HEIGHT));
	END;

	PROCEDURE plot(chr : CHAR; x,y,tCol,bgCol : INTEGER);
	BEGIN
		IF isInScreen(x,y) THEN
		BEGIN
			globalScreen[x, y].bgCol := bgCol;
			globalScreen[x, y].tCol  := tCol;
			globalScreen[x, y].chr   := chr;
		END;
	END;

	PROCEDURE renderPopUp(text : STRING);
	VAR
		x1, x2, y1, y2, i : INTEGER;
	BEGIN
		lastglobalScreen := globalScreen;
		x1 := 0;
		x2 := length(text) + 3;
		y1 := 0;
		y2 := 2;


		FOR i := x1 TO x2 - 1 DO
		BEGIN
			renderText(' ', i, y1, COL_RED, COL_RED);
			renderText(' ', i, y1 + 1, COL_RED, COL_RED);
			renderText(' ', i, y2, COL_RED, COL_RED);
		END;

		renderLine(x1, y1, x2, y1, COL_WHITE, COL_LRED);
		renderLine(x1, y2, x2, y2, COL_WHITE, COL_LRED);
		renderLine(x1, y1, x1, y2, COL_WHITE, COL_LRED);
		renderLine(x2, y1, x2, y2, COL_WHITE, COL_LRED);

		plot('+', x1, y1, COL_WHITE, COL_RED);
		plot('+', x2, y1, COL_WHITE, COL_RED);
		plot('+', x2, y2, COL_WHITE, COL_RED);
		plot('+', x1, y2, COL_WHITE, COL_RED);

		renderText(text, x1 + 2, y1 + 1, COL_WHITE, COL_RED);

		isInPopUp := True;
		render;
		readKey;
		globalScreen := lastglobalScreen;
	END;

	FUNCTION renderPopUpWithResponce(text : STRING) : CHAR;
	VAR
		x1, x2, y1, y2, i : INTEGER;
	BEGIN
		lastglobalScreen := globalScreen;
		x1 := 0;
		x2 := length(text) + 3;
		y1 := 0;
		y2 := 2;


		FOR i := x1 TO x2 - 1 DO
		BEGIN
			renderText(' ', i, y1, COL_RED, COL_RED);
			renderText(' ', i, y1 + 1, COL_RED, COL_RED);
			renderText(' ', i, y2, COL_RED, COL_RED);
		END;

		renderLine(x1, y1, x2, y1, COL_WHITE, COL_LRED);
		renderLine(x1, y2, x2, y2, COL_WHITE, COL_LRED);
		renderLine(x1, y1, x1, y2, COL_WHITE, COL_LRED);
		renderLine(x2, y1, x2, y2, COL_WHITE, COL_LRED);

		plot('+', x1, y1, COL_WHITE, COL_RED);
		plot('+', x2, y1, COL_WHITE, COL_RED);
		plot('+', x2, y2, COL_WHITE, COL_RED);
		plot('+', x1, y2, COL_WHITE, COL_RED);

		renderText(text, x1 + 2, y1 + 1, COL_WHITE, COL_RED);

		isInPopUp := True;
		render;
		globalScreen := lastglobalScreen;
		renderPopUpWithResponce := readKey;
	END;

	PROCEDURE renderPion(x,y : INTEGER; pion : pion);
	BEGIN
		//plot(FOR_TAB[pion.forme,1],     x, y, COL_WHITE, COL_TAB[pion.couleur]);
		//plot(FOR_TAB[pion.forme,2], x + 1, y, COL_WHITE, COL_TAB[pion.couleur]);
	END;
	
	PROCEDURE renderPionInGrille(x,y : INTEGER; pion : pion);
	BEGIN
		//plot(FOR_TAB[pion.forme,1], 2 * x - 1 + 4, y + 4, COL_WHITE, COL_TAB[pion.couleur]);
		//plot(FOR_TAB[pion.forme,2],     2 * x + 4, y + 4, COL_WHITE, COL_TAB[pion.couleur]);
	END;

	PROCEDURE renderTitle(title : STRING);
	BEGIN
		renderText('                                                  ', 1, 1, COL_WHITE,COL_BLACK);
		renderText(title, 1, 1, COL_WHITE,COL_BLACK);
	END;

	PROCEDURE renderMenuBorder(g : grille);
	BEGIN
		calculBordure(g);
		// carre bordure
		renderLine(        0,      0, WIDTH - 1,      0, 7, 0);
		renderLine(        0,      0,         0, HEIGHT - 1, 7, 0);
		renderLine(        0, HEIGHT - 1, WIDTH - 1, HEIGHT - 1, 7, 0);
		renderLine(WIDTH - 1,      0, WIDTH - 1, HEIGHT - 1, 7, 0);
		plot('+',0,0,7,0);
		plot('+',0,HEIGHT - 1,7,0);
		plot('+',WIDTH - 1,0,7,0);
		plot('+',WIDTH - 1,HEIGHT - 1,7,0);
		
		renderNumber(2,3, 2 * xSeparation + 1, 3);
		renderNumber(1,4, 1, 2 * xSeparation + 3);
		
		// ligne separation grille et histo
		renderLine(4 * xSeparation + 4, 0, 4 * xSeparation + 4, HEIGHT - 1, 7, 0); 
		plot('+', 4 * xSeparation + 4, 0, 7, 0);
		plot('+', 4 * xSeparation + 4, HEIGHT - 1, 7, 0);
		renderLine(0, 2, 4 * xSeparation + 4, 2, 7, 0); 
		plot('+', 0, 2, 7, 0);
		plot('+', 4 * xSeparation + 4, 2, 7, 0);
		
		renderLine(0, HEIGHT - 5, 4 * xSeparation + 4, HEIGHT - 5, 7, 0); 
		plot('+', 0, HEIGHT - 5, 7, 0);
		plot('+', 4 * xSeparation + 4, HEIGHT - 5, 7, 0);
	END;

	PROCEDURE renderMain(x,y, joueur : INTEGER ; main : tabPion);
	VAR
		i : INTEGER;
	BEGIN
		renderText('Votre main, joueur ' + inttostr(joueur) + ' :', 2, HEIGHT - 4, COL_WHITE, COL_BLACK);
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			renderPion(x+i*2,y,main[i]);
		END;
	END;

	PROCEDURE renderNodeHistorique(node : dataHistorique; i : INTEGER);
	VAR
		x,y : INTEGER;
	BEGIN
		x := 58;
		y := 10;
		IF node.id >= 0 THEN
		BEGIN
			renderText('MOV ' + inttostr(node.id), x, y, COL_WHITE, COL_BLACK );
			CASE node.joueur OF
				'J1' : renderText(node.joueur, x + 7, y, COL_LBLUE, COL_WHITE);
				'J2' : renderText(node.joueur, x + 7, y, COL_LBLUE, COL_RED);
				ELSE renderText(node.joueur, x + 7, y, COL_LBLUE, COL_WHITE);
			END;
			renderPion(x + 10, y, node.pion);
			renderText('x: ' + inttostr(node.posX), x + 14, y, COL_GREEN, COL_BLACK);
			renderText(', y: ' + inttostr(node.posY), x + 20, y, COL_GREEN, COL_BLACK);
		END;
	END;

	PROCEDURE renderHistorique;
	VAR
		i : INTEGER;
	BEGIN
		FOR i := 0 TO 17 DO
		BEGIN
			renderNodeHistorique(historique[(i + historiqueIndex) MOD 17], i + 4);
		END;
	END;

	FUNCTION selectorPos(g: grille; x, y : INTEGER) : position;
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
		i := x;
		j := y;
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
		clrscr;
		renderPionInGrille(i, j, last[i - 2,j - 2]);
		render;
	END;

	FUNCTION remplacerMain(main : tabPion; joueur : INTEGER) : tabPion;
	VAR
		i, j, pionNonNull : integer;
		finalPion : tabPion;
		change : ARRAY [0..5] OF BOOLEAN;
		ch : char;
		stop : BOOLEAN;
	BEGIN
		FOR i := 0 TO 5 DO change[i] := False;
		renderMain(3, HEIGHT - 3, joueur, main);
		
		renderPopUp('utilisez les fleches et "F" pour finir');
		
		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			IF main[i].couleur <> 0 THEN inc(pionNonNull);
		END;
		
		i := 0;
		plot('/', 3 + i * 2, HEIGHT - 2, 7, 0);
		plot('\',  3 + i * 2 + 1,HEIGHT - 2, 7, 0);
		render;
		REPEAT
			REPEAT
				ch := readKey();
				plot(' ', 3 + i * 2, HEIGHT - 2, 7, 0);
				plot(' ',  3 + i * 2 + 1,HEIGHT - 2, 7, 0);
				FOR j := 0 TO 5 DO
				BEGIN
					IF change[j] THEN
					BEGIN
						plot('@', 3 + j * 2, HEIGHT - 2, 7, 0);
						plot('@',  3 + j * 2 + 1,HEIGHT - 2, 7, 0);
					END
					ELSE
					BEGIN
						plot(' ', 3 + j * 2, HEIGHT - 2, 7, 0);
						plot(' ',  3 + j * 2 + 1,HEIGHT - 2, 7, 0);
					END;
				END;
			
				CASE ch OF
					#77 : IF i < pionNonNull - 1 THEN inc(i);
					#75 : IF i > 0 THEN dec(i);
					'f' : stop := True;
				END;
				plot('/', 3 + i * 2, HEIGHT - 2, 7, 0);
				plot('\',  3 + i * 2 + 1,HEIGHT - 2, 7, 0);
				render;
			UNTIL (ch = #13) or stop;

			change[i] := not Change[i];

			clrscr;
			FOR j := 0 TO 5 DO
				BEGIN
					IF change[j] THEN
					BEGIN
						plot('@', 3 + j * 2, HEIGHT - 2, 7, 0);
						plot('@',  3 + j * 2 + 1,HEIGHT - 2, 7, 0);
					END
					ELSE
					BEGIN
						plot(' ', 3 + j * 2, HEIGHT - 2, 7, 0);
						plot(' ',  3 + j * 2 + 1,HEIGHT - 2, 7, 0);
					END;
				END;
			clrscr;
			render;
		UNTIL stop;

		FOR j := 0 TO 5 DO
		BEGIN
			IF change[j] THEN
			BEGIN
				setLength(finalPion, length(finalPion) + 1);
				finalPion[length(finalPion) - 1] := main[j];
			END;
		END;		
		
		remplacerMain := finalPion;
		
	END;

	FUNCTION selectorMain(main : tabPion; joueur : INTEGER) : pion;
	VAR
		hasPlaced, swapPion, stop : BOOLEAN;
		ch        : char;
		p         : pion;
		i, ii, pionNonNull : INTEGER;
	BEGIN
		FOR i := 1 TO 50 DO
		BEGIN
			FOR ii := 30 TO 32 DO
			BEGIN
				plot(' ', i, ii, 7, 0);
			END;
		END;

		i := 0;
		clrscr;
		renderMain(3, HEIGHT - 3, joueur, main);
		plot('/', 3, HEIGHT - 2, 7, 0);
		plot('\',  4,HEIGHT - 2, 7, 0);
		render;
		hasPlaced := False;
		swapPion := False;
		p.couleur := COULEUR_NULL;
		p.forme := FORME_NULL;
		stop := False;
		pionNonNull := 0;

		FOR i := 0 TO length(main) - 1 DO
		BEGIN
			IF main[i].couleur <> 0 THEN inc(pionNonNull);
		END;

		i := 0;

		REPEAT
			ch := readKey();
			plot(' ', 3 + i * 2, HEIGHT - 2, 7, 0);
			plot(' ',  3 + i * 2 + 1,HEIGHT - 2, 7, 0);
			CASE ch OF
				#77 : IF i < pionNonNull - 1 THEN inc(i);
				#75 : IF i > 0 THEN dec(i);
				#13 : hasPlaced := True;
				#114: swapPion := True;
				'q' : stop := True;
			END;
			clrscr;
			plot('/', 3 + i * 2, HEIGHT - 2, 7, 0);
			plot('\',  3 + i * 2 + 1,HEIGHT - 2, 7, 0);
			clrscr;
			render;
		UNTIL hasPlaced or swapPion or stop;
		IF hasPlaced THEN
			selectorMain := main[i];
		IF swapPion THEN
			selectorMain := p;
		IF stop THEN
		BEGIN
			p.couleur := -1;
			selectorMain := p;
		END;
	END;

	
	PROCEDURE renderGame(g : grille);
	VAR
		i,j : INTEGER;
	BEGIN
		clearScreen(0);
		calculBordure(g);
		renderMenuBorder(g);
		
		FOR i := 0 TO 2 * xSeparation - 1 DO
		BEGIN
			FOR j := 0 TO 2 * xSeparation - 1 DO
			BEGIN
				//g[(TAILLE_GRILLE DIV 2 + i),(TAILLE_GRILLE DIV 2) + j]
				renderPionInGrille(i, j, getPion(g, i, j));
			END;
		END;
	END;


	PROCEDURE addToHistorique(p : pion; x, y : INTEGER; joueur : STRING);
	BEGIN
		IF joueur <> 'T' THEN
		BEGIN
			historique[historiqueIndex MOD 18].pion   := p;
			historique[historiqueIndex MOD 18].posX   := x;
			historique[historiqueIndex MOD 18].posY   := y;
			historique[historiqueIndex MOD 18].id     := historiqueIndex;
			historique[historiqueIndex MOD 18].joueur := joueur;
			inc(historiqueIndex);
		END;
	END;

	PROCEDURE renderJoueurText(nbrJoueurHumain, nbrJoueurMachine : INTEGER);
	VAR
		i : INTEGER;
		textPos  : ARRAY [0..7] OF INTEGER = (54, 3, 79, 3, 54, 7, 79, 7);
		scorePos : ARRAY [0..7] OF INTEGER = (56, 5, 80, 5, 56, 5, 80, 9);
	BEGIN
		FOR i := 0 TO nbrJoueurHumain + nbrJoueurMachine - 1 DO
		BEGIN
			IF nbrJoueurHumain > 0 THEN
			BEGIN
				renderText('JOUEUR ' + inttostr(i) + ' :', textPos[i * 2], textPos[i * 2 + 1], COL_WHITE, COL_BLACK);
				dec(nbrJoueurHumain);
			END
			ELSE
			BEGIN
				IF nbrJoueurMachine > 0 THEN
				BEGIN
					renderText('ORDIN. ' + inttostr(i) + ' :', textPos[i * 2], textPos[i * 2 + 1], COL_WHITE, COL_BLACK);
					dec(nbrJoueurMachine);
				END;
			END;
		END;
	END;

	PROCEDURE renderScore(joueur, score : INTEGER);
	VAR
		scorePos : ARRAY [0..7] OF INTEGER = (56, 5, 82, 5, 56, 5, 80, 9);
	BEGIN
		renderText(' ' + inttostr(score), scorePos[joueur * 2], scorePos[joueur * 2 + 1], joueur MOD 7 + 1, COL_WHITE);
	END;
END.
