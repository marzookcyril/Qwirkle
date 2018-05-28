UNIT legal;
INTERFACE

USES constants  in '../core/constants.pas', crt,
	 structures in '../core/structures.pas';

FUNCTION remplirGrille(g : grille): grille;
FUNCTION calculVoisin ( g : grille ; pos : position) : INTEGER ;
FUNCTION rules(g : grille; pos: position ):BOOLEAN ;
FUNCTION verifLigne(g : grille ; p, pos : position): BOOLEAN;
FUNCTION verifColonne(g : grille ; p, pos : position): BOOLEAN;
FUNCTION posVoisin(g : grille ; pos : position): tabdyn;
FUNCTION tabVoisin(g : grille ; pos : position): matrice;
FUNCTION unVoisin(g :grille ;pos : position):BOOLEAN;
FUNCTION troisVoisins(g : grille; pos : position): BOOLEAN;
FUNCTION quatreVoisins(g : grille; pos : position): BOOLEAN;
FUNCTION posUnVoisin(g : grille; pos : position ) : position ;


IMPLEMENTATION

// Fonction qui permet d'initier une grille
// avec des formes et couleurs nulle

FUNCTION remplirGrille(g : grille): grille;
VAR i , j : INTEGER;
BEGIN
	FOR i := 0 TO TAILLE_GRILLE -1 DO
	BEGIN
		FOR j := 0 TO TAILLE_GRILLE -1 DO
		BEGIN
			g[i,j].couleur := COULEUR_NULL;
			g[i,j].forme   := FORME_NULL;
		END;
	END;
	remplirGrille := g;
END;





// Fonciton qui permet de calculer le
// nombre de voisins autour de la position
// ou l'on veut placer le nouveau pion
FUNCTION calculVoisin ( g : grille ; pos : position) : INTEGER ;
VAR x : INTEGER;
BEGIN
	x := 0;
	IF g[pos.x+1 , pos.y].couleur <> 0 THEN
		x := x +1;
	IF g[pos.x-1 , pos.y].couleur <> 0 THEN
		x := x +1;
	IF g[pos.x , pos.y+1].couleur <> 0 THEN
		x := x +1;
	IF g[pos.x+1 , pos.y-1].couleur <> 0 THEN
		x := x +1;
	calculVoisin := x;
END;



//   Fonction qui permet de verifier si on peut placer
//   le pion sur la ligne en verifiant si on forme une ligne
//   avec la couleur ou la forme.
//   Ensuite on verifie qu'il n'y ait pas deja une ligne
//   complete de forme ou couleur.

FUNCTION verifLigne(g : grille ; p, pos : position): BOOLEAN;
VAR x, y, i : INTEGER;
BEGIN
	x := 1;
	y := 1;
	IF pos.x-1 = p.x THEN
	BEGIN
		IF (((g[p.x-1,p.y].couleur = g[pos.x, pos.y].couleur) AND   (g[p.x-1,p.y].forme <> g[pos.x, pos.y].forme)) OR ((g[p.x-1,p.y].couleur <> g[pos.x, pos.y].couleur) AND   (g[p.x-1,p.y].forme = g[pos.x, pos.y].forme)) OR (g[p.x-1,p.y].couleur = 0)) THEN
			verifLigne := TRUE
		ELSE
			verifLigne := FALSE;
	END
	ELSE
	BEGIN
		IF (((g[p.x+1,p.y].couleur = g[pos.x, pos.y].couleur) AND   (g[p.x+1,p.y].forme <> g[pos.x, pos.y].forme)) OR ((g[p.x+1,p.y].couleur <> g[pos.x, pos.y].couleur) AND   (g[p.x+1,p.y].forme = g[pos.x, pos.y].forme)) OR (g[p.x+1,p.y].couleur = 0))  THEN
			verifLigne := TRUE
		ELSE
			verifLigne := FALSE;
	END;
	IF g[pos.x-1,pos.y].couleur <> 0 THEN
	BEGIN
		FOR i := 2 TO 6 DO
		BEGIN
			IF g[pos.x-i,pos.y].couleur <> 0 THEN
				inc(x);
		END;
	END;
	IF g[pos.x+1,pos.y].couleur <> 0 THEN
	BEGIN
		FOR i := 2 TO 6 DO
		BEGIN
			IF g[pos.x+1,pos.y].couleur <> 0 THEN
				inc(y);
		END;
	END;
	IF (x = 6) OR (y = 6) THEN
		verifLigne := FALSE;
END;




//   Fonction qui permet de verifier si on peut placer
//   le pion sur la colonne en verifiant si on forme une colonne
//   avec la couleur ou la forme.
//   Ensuite on verifie qu'il n'y ait pas deja une colonne
//   complete de forme ou couleur.

FUNCTION verifColonne(g : grille ; p, pos : position): BOOLEAN;
VAR x,y,i : INTEGER;
BEGIN
	x :=1;
	y :=1;
	IF pos.y-1 = p.y THEN
	BEGIN
		IF (((g[p.x,p.y-1].couleur = g[pos.x, pos.y].couleur) AND   (g[p.x,p.y-1].forme <> g[pos.x, pos.y].forme)) OR ((g[p.x,p.y-1].couleur <> g[pos.x, pos.y].couleur) AND   (g[p.x,p.y-1].forme = g[pos.x, pos.y].forme)) OR (g[p.x,p.y-1].couleur = 0)) THEN
			verifColonne := TRUE
		ELSE
			verifColonne := FALSE;
	END
	ELSE
	BEGIN
		IF (((g[p.x,p.y+1].couleur = g[pos.x, pos.y].couleur) AND   (g[p.x,p.y+1].forme <> g[pos.x, pos.y].forme)) OR ((g[p.x,p.y+1].couleur <> g[pos.x, pos.y].couleur) AND   (g[p.x,p.y+1].forme = g[pos.x, pos.y].forme)) OR (g[p.x,p.y+1].couleur = 0))  THEN
			verifColonne := TRUE
		ELSE
			verifColonne := FALSE;
	END;
	IF g[pos.x,pos.y-1].couleur <> 0 THEN
	BEGIN
		FOR i := 2 TO 6 DO
		BEGIN
			IF g[pos.x,pos.y-i].couleur <> 0 THEN
				inc(x);
		END;
	END;
	IF g[pos.x,pos.y+1].couleur <> 0 THEN
	BEGIN
		FOR i := 2 TO 6 DO
		BEGIN
			IF g[pos.x,pos.y+i].couleur <> 0 THEN
				inc(y);
		END;
	END;
	IF (x = 6) OR (y = 6) THEN
		verifColonne := FALSE;
END;



FUNCTION posVoisin(g : grille ; pos : position): tabdyn;
VAR
	tabdy : tabdyn;
	nbrV ,i  : INTEGER;
BEGIN
	nbrV := calculVoisin(g,pos);
	setlength(tabdy,(2*nbrV)-1);
	i := 0;
	IF (g[pos.x,pos.y-1].couleur <> 0) THEN
	BEGIN
		tabdy[i] := pos.x;
		tabdy[i+1] := pos.y-1;
		i := i+2;
	END;
	IF (g[pos.x,pos.y+1].couleur <> 0) THEN
	BEGIN
		tabdy[i] := pos.x;
		tabdy[i+1] := pos.y+1;
		i := i+2;
	END;
	IF (g[pos.x-1,pos.y].couleur <> 0) THEN
	BEGIN
		tabdy[i] := pos.x-1;
		tabdy[i+1] := pos.y;
		i := i+2;
	END;
	IF (g[pos.x+1,pos.y].couleur <> 0) THEN
	BEGIN
		tabdy[i] := pos.x+1;
		tabdy[i+1] := pos.y;
		i := i+2;
	END;
	posVoisin := tabdy;

END;




//  Fonction qui permet de renvoyer la position du voisin quand il y en
//  a qu'un seul.
FUNCTION posUnVoisin(g : grille; pos : position ) : position ;
VAR p       : position;
BEGIN
	IF (g[pos.x,pos.y-1].couleur <> 0) THEN
	BEGIN
				p.x     := pos.x;
				p.y     := pos.y-1;
			END
			ELSE
			BEGIN
				IF g[pos.x,pos.y+1].couleur <> 0 THEN
				BEGIN
					p.x     := pos.x;
					p.y     := pos.y+1;
				END
				ELSE
				BEGIN
					IF g[pos.x-1,pos.y].couleur <> 0 THEN
					BEGIN
						p.x   := pos.x-1;
						p.y   := pos.y;
					END
					ELSE
					BEGIN
						p.x   := pos.x+1;
						p.y   := pos.y;
					END;
				END;
	END;
			posUnVoisin := p;
END;




FUNCTION tabVoisin(g : grille ; pos : position): matrice;
VAR tab : matrice;
	i,j : INTEGER;
BEGIN
	FOR i := 0 TO 2 DO 
	BEGIN
		FOR j := 0 TO 2 DO 
		BEGIN
			tab[i,j].couleur := 0;
			tab[i,j].forme := 0;
		END;
	END;
	IF g[pos.x+1,pos.y].couleur <> 0 THEN 
		tab[2,1] := g[pos.x+1,pos.y];
	IF g[pos.x-1,pos.y].couleur <> 0 THEN 
		tab[0,1] := g[pos.x+1,pos.y];
	IF g[pos.x,pos.y+1].couleur <> 0 THEN 
		tab[1,0] := g[pos.x,pos.y+1];
	IF g[pos.x,pos.y-1].couleur <> 0 THEN 
		tab[1,2] := g[pos.x,pos.y-1];
	tabVoisin := tab;
END;

FUNCTION unVoisin(g :grille ;pos : position):BOOLEAN;
VAR p1 : position;
BEGIN
	p1 := posUnVoisin(g ,pos);
	IF ((( (g[p1.x,p1.y].couleur = g[pos.x,pos.y].couleur) AND (g[p1.x,p1.y].forme <> g[pos.x,pos.y].forme)) OR ((g[p1.x,p1.y].couleur <> g[pos.x,pos.y].couleur) AND (g[p1.x,p1.y].forme = g[pos.x,pos.y].forme))) AND ( verifColonne(g,p1,pos) AND verifLigne(g,p1,pos) )) THEN
				unVoisin:= TRUE
			ELSE
				unVoisin := FALSE;
END;


//Fonction qui verifie si le coup est
// possible avec trois voisins
FUNCTION troisVoisins(g : grille; pos : position): BOOLEAN;
VAR p1,p2,p3 : position;
	tabd      : tabdyn;
	tab ,tabe	  : matrice;
BEGIN
	tab := tabVoisin(g,pos);
	tabd := posVoisin(g,pos);
	p1.x := tabd[0];
	p1.y := tabd[1];
	p2.x := tabd[2];
	p2.y := tabd[3];
	p3.x := tabd[4];
	p3.y := tabd[5];
	tabe :=tab;
	IF tab[2,1].couleur = 0 THEN 
	BEGIN
		IF ((tab[1,0].forme = tab[1,2].forme) AND (tab[1,0].forme = g[pos.x,pos.y].forme)) THEN 
		BEGIN
			tabe[1,1] := tabe[1,2];
			tabe[0,1] := tabe[2,1];
		END;
	END;
END;





FUNCTION quatreVoisins(g : grille; pos : position): BOOLEAN;
VAR p1, p2, p3, p4 : position;
	tabd  		   : tabdyn;
	tab			   : matrice;
BEGIN
	tabd := posVoisin(g,pos);
	p1.x := tabd[0];
	p1.y := tabd[1];
	p2.x := tabd[2];
	p2.y := tabd[3];
	p3.x := tabd[4];
	p3.y := tabd[5];
	p4.x := tabd[6];
	p4.y := tabd[7];




END;



//  Fonction qui permet de dire s'il est possible
// 	de faire un coup ou non.
FUNCTION rules(g : grille; pos: position ):BOOLEAN ;
VAR  temp          : INTEGER;
	p1, p2, p3, P4 : position;
	tab            : tabdyn;
BEGIN
	temp := calculVoisin(g,pos);
	CASE temp OF
		1 :
		BEGIN
			IF unVoisin(g,pos) THEN
				rules := TRUE
			ELSE
				rules := FALSE;
		END;
		2 :
		BEGIN
			tab := posVoisin(g,pos);
			p1.x := tab[0];
			p1.y := tab[1];
			p2.x := tab[2];
			p2.y := tab[3];
			IF ((((g[p1.x,p1.y].couleur = g[p2.x,p2.y].couleur) AND (g[p1.x,p1.y].couleur= g[pos.x,pos.y].couleur)) AND ((g[p1.x,p1.y].forme <> g[p2.x,p2.y].forme) AND (g[p1.x,p1.y].forme <> g[pos.x,pos.y].forme) AND (g[p2.x,p2.y].forme <> g[pos.x,pos.y].forme))) OR (((g[p1.x,p1.y].forme = g[p2.x,p2.y].forme) AND (g[p1.x,p1.y].forme = g[pos.x,pos.y].forme)) AND ((g[p1.x,p1.y].couleur <> g[p2.x,p2.y].couleur) AND (g[p1.x,p1.y].couleur <> g[pos.x,pos.y].couleur) AND (g[p2.x,p2.y].couleur <> g[pos.x,pos.y].couleur))) AND ((verifColonne(g,p1,pos) AND verifLigne(g,p1,pos) AND verifColonne(g,p2,pos) AND verifLigne(g,p2,pos)))) THEN
				rules := TRUE
			ElSE
				rules := FALSE;
		END;
		3 :
		BEGIN
			IF troisVoisins(g,pos) THEN
				rules := TRUE
			ELSE
				rules := FALSE;
		END;
		4:
		BEGIN
			IF quatreVoisins(g,pos) THEN
				rules := TRUE
			ELSE
				rules := FALSE;
		END;
END;

END;




END.
