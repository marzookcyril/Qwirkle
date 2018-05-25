UNIT legal;
INTERFACE

USES constants  in '../core/constants.pas', crt,
	 structures in '../core/structures.pas';

FUNCTION remplirGrille(g : grille): grille;
FUNCTION calculVoisin ( g : grille ; pos : position) : INTEGER ;
FUNCTION rules(g : grille; pos: position ):BOOLEAN ;
FUNCTION verifLigne(g : grille ; p, pos : position): BOOLEAN;
FUNCTION verifColonne(g : grille ; p, pos : position): BOOLEAN;
FUNCTION unVoisin(g : grille; pos : position ) : position ;


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
			g[i,j].couleur := COULEUR_NUL;
			g[i,j].forme   := FORME_NUL;
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


//  Fonction qui permet de renvoyer la position du voisin quand il y en
//  a qu'un seul.
FUNCTION unVoisin(g : grille; pos : position ) : position ;
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
			unVoisin := p;
END;


//  Fonction qui permet de dire s'il est possible 
// 	de faire un coup ou non.
FUNCTION rules(g : grille; pos: position ):BOOLEAN ;
VAR  temp : INTEGER;
	p : position;
BEGIN
	temp := calculVoisin(g,pos);
	CASE temp OF 
		1 :
		BEGIN
			p := unVoisin(g ,pos);
			IF ((( (g[p.x,p.y].couleur = g[pos.x,pos.y].couleur) AND (g[p.x,p.y].forme <> g[pos.x,pos.y].forme)) OR ((g[p.x,p.y].couleur <> g[pos.x,pos.y].couleur) AND (g[p.x,p.y].forme = g[pos.x,pos.y].forme))) AND ( verifColonne(g,p,pos) AND verifLigne(g,p,pos) )) THEN 
				rules := TRUE
			ELSE 
				rules := FALSE;
		END;
		2 : 
		BEGIN
		
		
		END;
			
END;

END;




END.
