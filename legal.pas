UNIT legal;
INTERFACE
USES constants  in 'core/constants.pas', sysutils, Math,
	structures in 'core/structures.pas';

FUNCTION calculNombreDeVoisin(g : grille; x, y : INTEGER; dirInt : INTEGER) : INTEGER;
FUNCTION verifNombreVoisin(g : grille; x, y: INTEGER) : BOOLEAN;
FUNCTION findEtat(g : grille; x,y, dirInt : INTEGER) : STRING;
FUNCTION concordance(g : grille; x, y : INTEGER) : BOOLEAN;
FUNCTION concordanceGenerale(g: grille ; x,y : INTEGER; p : pion): BOOLEAN;
FUNCTION duplicationPion(g : grille; x,y  : INTEGER; p : pion) : BOOLEAN;
FUNCTION placer(g: grille; x, y : INTEGER; p : pion): BOOLEAN;
FUNCTION isLegal(g: grille; x, y : INTEGER; p : pion; isFirst : BOOLEAN): BOOLEAN;
FUNCTION plusieursCoups(g: grille; x1,y1,x2,y2: INTEGER; p1,p2 : pion) : BOOLEAN;
FUNCTION nCoups(g: grille; x1,y1,x2,y2,x3,y3,num : INTEGER; p1,p2,p3 : pion) : BOOLEAN;
FUNCTION initTabPos(): tabPos;
PROCEDURE choperPos(VAR t : tabPos ; x,y, num : INTEGER);
FUNCTION point(g : grille; t : tabPos ; num : INTEGER): INTEGER;
FUNCTION continu(g: grille ;x1,y1,x2,y2 : INTEGER): BOOLEAN;


IMPLEMENTATION

	// dir :    2
	//        1   3
	//          4
	FUNCTION dirValue(dir : INTEGER) : position;
	VAR
		tmp : position;
	BEGIN
		CASE dir OF
			1 : BEGIN
				tmp.x := -1;
				tmp.y := 0;
			END;
			2 : BEGIN
				tmp.x := 0;
				tmp.y := -1;
			END;
			3 : BEGIN
				tmp.x := 1;
				tmp.y := 0;
			END;
			4 : BEGIN
				tmp.x := 0;
				tmp.y := 1;
			END;
		END;
		dirValue := tmp;
	END;

	FUNCTION calculNombreDeVoisin(g : grille; x, y: INTEGER; dirInt : INTEGER) : INTEGER;
	VAR
		i : INTEGER;
		dir : position;
	BEGIN
		i := 0;
		dir := dirValue(dirInt);
		WHILE g[x + (i+1) * dir.x, y + (i+1) * dir.y].forme <> FORME_NULL DO
			inc(i);
		calculNombreDeVoisin := i;
	END;

	FUNCTION verifNombreVoisin(g : grille; x, y: INTEGER) : BOOLEAN;
	VAR
		verif : BOOLEAN;
	BEGIN
		verif := TRUE;
		IF NOT (calculNombreDeVoisin(g,x,y,1) + (calculNombreDeVoisin(g,x,y,3)) <= 5) THEN
			verif := FALSE;
		IF NOT (calculNombreDeVoisin(g,x,y,2) + (calculNombreDeVoisin(g,x,y,4)) <= 5) THEN
			verif := FALSE;
		verifNombreVoisin := verif;
	END;

	// CODES :
	// 000 => free
	// 404 => error
	FUNCTION findEtat(g : grille; x,y, dirInt : INTEGER) : STRING;
	VAR
		dir, dirBis : position;
		nbrVoisin, nbrVoisinPeu : INTEGER;
	BEGIN
		dir := dirValue(dirInt);
		nbrVoisin := calculNombreDeVoisin(g, x, y, dirInt);
		IF nbrVoisin > 1 THEN
		BEGIN
			IF g[x + dir.x, y + dir.y].forme = g[x + 2 * dir.x, y + 2 * dir.y].forme THEN
			BEGIN
				findEtat :=  'F' + inttostr(g[x + dir.x, y + dir.y].forme) + '0';
			END
			ELSE
			BEGIN
				IF g[x + dir.x, y + dir.y].couleur = g[x + 2 * dir.x, y + 2 * dir.y].couleur THEN
					findEtat :=  'C' + inttostr(g[x + dir.x, y + dir.y].couleur) + '0'
				ELSE
					findEtat := '404';
			END;
		END
		ELSE
		BEGIN
			IF nbrVoisin = 0 THEN
			BEGIN
				nbrVoisinPeu := calculNombreDeVoisin(g, x, y, (dirInt + 2) MOD 4);
				dir := dirValue((dirInt + 2) MOD 4);
				// le voisin opposé est seul
				IF nbrVoisinPeu = 0 THEN
					findEtat := '000';
				IF nbrVoisinPeu = 1 THEN
					findEtat := '0' + inttostr(g[x + dir.x, y + dir.y].forme) + inttostr(g[x + dir.x, y + dir.y].couleur);
				IF nbrVoisinPeu > 1 THEN
				BEGIN
					IF g[x + dir.x, y + dir.y].forme = g[x + 2 * dir.x, y + 2 * dir.y].forme THEN
						findEtat :=  'F' + inttostr(g[x + dir.x, y + dir.y].forme) + '0';
					IF g[x + dir.x, y + dir.y].couleur = g[x + 2 * dir.x, y + 2 * dir.y].couleur THEN
						findEtat :=  'C' + inttostr(g[x + dir.x, y + dir.y].couleur) + '0';
				END;
			END
			ELSE
			BEGIN
				dirBis := dirValue((dirInt + 2) MOD 4);
				IF g[x + dirBis.x, y + dirBis.y].forme <> 0 THEN
				BEGIN
					IF g[x + dir.x, y + dir.y].forme = g[x + dirBis.x, y + dirBis.y].forme THEN
					BEGIN
						findEtat :=  'F' + inttostr(g[x + dir.x, y + dir.y].forme) + '0';
					END
					ELSE
					BEGIN
						IF g[x + dir.x, y + dir.y].couleur = g[x + dirBis.x, y + dirBis.y].couleur THEN
						BEGIN
							findEtat :=  'C' + inttostr(g[x + dir.x, y + dir.y].couleur) + '0';
						END
						ELSE
							findEtat := '404';
					END;
				END
				ELSE
					findEtat := '0' + inttostr(g[x + dir.x, y + dir.y].forme) + inttostr(g[x + dir.x, y + dir.y].couleur);
			END;
		END;
	END;

	// dir => 0 en ligne, 1 => en colonnne
	FUNCTION sousConcordance(g : grille; x, y, dir : INTEGER) : BOOLEAN;
	VAR
		etat1, etat2 : STRING;
	BEGIN
		etat1 := findEtat(g, x, y, dir + 1);
		etat2 := findEtat(g, x, y, dir + 3);

		IF (etat1 = etat2) AND (etat1 <> '404') THEN
			sousConcordance := TRUE
		ELSE
			sousConcordance := FALSE;
	END;

	FUNCTION concordance(g : grille; x, y : INTEGER) : BOOLEAN;
	BEGIN
		concordance := sousConcordance(g, x, y, 1) AND sousConcordance(g, x, y, 0);
	END;

	FUNCTION concordanceGenerale(g: grille ; x,y : INTEGER; p : pion): BOOLEAN;
	VAR
		i , j: INTEGER;
		etat1 : STRING;
	BEGIN
		i :=0;
		FOR j := 1 TO 2 DO
		BEGIN
			etat1 := findEtat(g, x, y, j);
			IF ( etat1[1] = '0' ) THEN
			BEGIN
				IF (inttostr(p.couleur) = etat1[3]) OR (inttostr(p.forme) =  etat1[2]) THEN
					inc(i);
			END;
			IF ( etat1[1] = 'F') THEN
			BEGIN
				IF inttostr(p.forme) = etat1[2] THEN
					inc(i);
			END;
			IF ( etat1[1] = 'C') THEN
			BEGIN
				IF inttostr(p.couleur) = etat1[2] THEN
					inc(i);
			END;
		END;
		IF i = 2 THEN
			concordanceGenerale := TRUE
		ELSE
			concordanceGenerale := FALSE;
	END;

	FUNCTION injection(x, y : INTEGER) :  INTEGER;
	BEGIN
		injection := ((x + y) * (x + y + 1)) DIV 2 + y;
	END;

	// 1 en ligne / 2 en colonne
	FUNCTION duplicationPion(g : grille; x,y: INTEGER; p : pion) : BOOLEAN;
	VAR
		// magie de paul
		tmp : ARRAY [0..83] OF INTEGER;
		erreur : boolean;
		i, ii : INTEGER;
	BEGIN
		g[x,y] := p;
		erreur := FALSE;

		FOR i := 0 TO 83 DO
			tmp[i] := 0;




		i := x - calculNombreDeVoisin(g, x, y, 1);
		WHILE NOT erreur AND (i <= x + calculNombreDeVoisin(g, x, y, 3)) DO
			IF tmp[injection(g[i, y].forme, g[i, y].couleur)] <> 0 THEN
			BEGIN
				writeln(inttostr(i) + ', ' +inttostr(y) + ' , ' + inttostr(g[i, y].couleur) + ','+ inttostr(tmp[injection(g[i, y].forme, g[i, y].couleur)]));
				erreur := TRUE;
			END
			ELSE
			BEGIN
				tmp[injection(g[i, y].forme, g[i, y].couleur)] := 1;
				inc(i);
			END;

		FOR i := 0 TO 77 DO
			tmp[i] := 0;

		i := y - calculNombreDeVoisin(g, x, y, 2);
		WHILE NOT erreur AND (i <= y + calculNombreDeVoisin(g, x, y, 4)) DO
			IF tmp[injection(g[x, i].forme, g[x, i].couleur)] <> 0 THEN
			BEGIN
				writeln(inttostr(x) + ', ' +inttostr(i));
				erreur := TRUE;
			END
			ELSE
			BEGIN
				tmp[injection(g[x, i].forme, g[x, i].couleur)] := 1;
				inc(i);
			END;


		duplicationPion := NOT erreur;
	END;


	FUNCTION isLegal(g: grille; x, y : INTEGER; p : pion; isFirst : BOOLEAN): BOOLEAN;
	BEGIN
		IF isFirst THEN
			isLegal := TRUE
		ELSE
		BEGIN
			IF concordanceGenerale(g,x,y,p) AND duplicationPion(g,x,y,p) THEN
				isLegal := TRUE
			ELSE
				isLegal := FALSE;
		END;
	END;

	FUNCTION placer(g: grille; x, y : INTEGER; p : pion): BOOLEAN;
	BEGIN
		IF concordanceGenerale(g,x,y,p) AND duplicationPion(g,x,y,p) THEN
			placer := TRUE
		ELSE
			placer := FALSE;
	END;

	FUNCTION continu(g: grille ;x1,y1,x2,y2 : INTEGER): BOOLEAN;
	VAR 
		cont: BOOLEAN;
	BEGIN
		cont := FALSE;
		IF x1 = x2 THEN 
		BEGIN 
			IF ((x2 > x1 - 6) AND (x2 < x1 + 6)) THEN 
				cont := TRUE;
		END;
		IF y1 = y2 THEN 
		BEGIN 
			IF ((y2 > y1 - 6) AND (y2 < y1 + 6)) THEN 
				cont := TRUE;
		END;
		continu := cont;
	END;


	FUNCTION plusieursCoups(g: grille; x1,y1,x2,y2 : INTEGER; p1,p2 : pion) : BOOLEAN;
	VAR
		s1,s2 : STRING;
	BEGIN
		s1 := findEtat(g, x1, y1, 2);
		s2 := findEtat(g, x1, y1, 3);
		IF p2.couleur = p1.couleur THEN
		BEGIN
			IF (((s1[1] = 'C') AND (s1[2]= intToStr(p2.couleur))OR ((s1[1]= '0') AND ( s1[3] = intToStr(p2.couleur))))) THEN
			BEGIN
				IF ((placer(g,x2,y2,p2)) AND (x1=x2)) THEN
					plusieursCoups := TRUE
				ELSE
					plusieursCoups := FALSE ;
			END
			ELSE
			BEGIN
				IF (((s2[1] = 'C') AND (s2[2]= intToStr(p2.couleur))OR ((s2[1]= '0') AND ( s2[3] = intToStr(p2.couleur))))) THEN
				BEGIN
					IF ((placer(g,x2,y2,p2)) AND (x1=x2)) THEN
						plusieursCoups := TRUE
					ELSE
						plusieursCoups := FALSE;
				END;
			END;
		END;
		IF p2.forme = p1.forme THEN
		BEGIN
			IF (((s1[1] = 'F') AND (s1[2]= intToStr(p2.forme))OR ((s1[1]= '0') AND ( s1[2] = intToStr(p2.forme))))) THEN
			BEGIN
				IF ((placer(g,x2,y2,p2)) AND (y1=y2)) THEN
					plusieursCoups := TRUE
				ELSE
					plusieursCoups := FALSE;
			END
			ELSE
			BEGIN
				IF (((s2[1] = 'F') AND (s2[2]= intToStr(p2.forme))OR ((s2[1]= '0') AND ( s2[2] = intToStr(p2.forme))))) THEN
				BEGIN
					IF ((placer(g,x2,y2,p2)) AND (y1=y2)) THEN
						plusieursCoups := TRUE
					ELSE
						plusieursCoups := FALSE;
				END;
			END;
		END;
		IF ((p2.couleur<> p1.couleur) AND (p2.forme <> p1.forme)) THEN
			plusieursCoups := FALSE;
	END;


	FUNCTION nCoups(g: grille; x1,y1,x2,y2,x3,y3,num : INTEGER; p1,p2,p3 : pion) : BOOLEAN;
	BEGIN
		CASE num OF
			1 :
			BEGIN
				IF placer(g,x1,y1,p1) THEN
					nCoups := TRUE
				ELSE
					nCoups := FALSE;
			END;
			2 :
			BEGIN
				IF plusieursCoups(g, x1,y1,x2,y2, p1,p2) THEN
					nCoups := TRUE
				ELSE
					nCoups := FALSE;
			END
		ELSE
		BEGIN
			IF (num > 2) THEN
			BEGIN
				IF plusieursCoups(g,x1,y1,x3,y3,p1,p3) AND plusieursCoups(g,x1,y1,x2,y2,p1,p2) THEN
					nCoups := TRUE
				ELSE
					nCoups := FALSE;
			END;
		END;
	END;
	END;
	FUNCTION initTabPos(): tabPos;
	VAR i : INTEGER;
		t : tabPos;
	BEGIN
		FOR i := 0 TO 5 Do 
		BEGIN 
			t[i].x := 0;
			t[i].y := 0;
		END;
		initTabPos := t;
	END;
	
	PROCEDURE choperPos(VAR t : tabPos ; x,y, num : INTEGER);
    BEGIN
        t[num-1].x  := x;
		t[num-1].y  := y;
    END;
    
    
    FUNCTION point(g : grille; t : tabPos ; num : INTEGER): INTEGER;
    VAR i ,points : INTEGER;
    BEGIN
        points := 0;
        IF ((t[1].x <> 0) AND (t[0].x = t[1].x)) THEN
        BEGIN
            FOR i := 1 TO num DO 
            BEGIN
                IF calculNombreDeVoisin(g,t[i-1].x,t[i-1].y,1) <> 0 THEN 
                BEGIN
                    IF calculNombreDeVoisin(g,t[i-1].x,t[i-1].y,1) = 5 THEN
                        points := points + 12
                    ELSE
                        points := points + 1 + calculNombreDeVoisin(g,t[i-1].x,t[i-1].y,1) ; 
                END;
            IF calculNombreDeVoisin(g,t[0].x,t[0].y,3) =5 THEN 
                points := points + 12
            ELSE 
                points := points + 1 + calculNombreDeVoisin(g,t[0].x,t[0].y,3);
            END;
        END;
         IF ((t[1].x <> 0) AND (t[0].y = t[1].y)) THEN
        BEGIN
            FOR i := 1 TO num DO 
            BEGIN
                IF calculNombreDeVoisin(g,t[i-1].x,t[i-1].y,3) <> 0 THEN 
                BEGIN
                    IF calculNombreDeVoisin(g,t[i-1].x,t[i-1].y,3) = 5 THEN
                        points := points + 12
                    ELSE
                        points := points + 1 + calculNombreDeVoisin(g,t[i-1].x,t[i-1].y,3) ; 
                END;
            IF calculNombreDeVoisin(g,t[0].x,t[0].y,1) =5 THEN 
                points := points + 12
            ELSE 
                points := points + 1 + calculNombreDeVoisin(g,t[0].x,t[0].y,1);
            END;
        END;
        IF num = 1 THEN 
		BEGIN
			IF calculNombreDeVoisin(g,t[0].x,t[0].y,1) =5 THEN 
				points := points + 12
			ELSE 
				points := points + 1 + calculNombreDeVoisin(g,t[0].x,t[0].y,1);
			IF calculNombreDeVoisin(g,t[0].x,t[0].y,3) =5 THEN 
				points := points + 12
			ELSE 
				points := points + 1 + calculNombreDeVoisin(g,t[0].x,t[0].y,3);
		END;
        point := points; 
    END;
    


END.