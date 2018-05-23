UNIT legal;
INTERFACE

USES constants  in '../core/constants.pas', crt,
	 structures in '../core/structures.pas';

FUNCTION remplirGrille(g : grille): grille;
FUNCTION rules(g : grille; pos: position ):BOOLEAN ;



IMPLEMENTATION

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



FUNCTION unVoisin(g : grille; pos : position ) : position ;
VAR p : position;
BEGIN
	IF (g[pos.x,pos.y-1].couleur <> 0) THEN
	BEGIN
				p.x := pos.x;
				p.y := pos.y-1;
			END
			ELSE
			BEGIN
				IF g[pos.x,pos.y+1].couleur <> 0 THEN 
				BEGIN
					p.x := pos.x;
					p.y := pos.y+1;
				END
				ELSE
				BEGIN
					IF g[pos.x-1,pos.y].couleur <> 0 THEN 
					BEGIN
						p.x := pos.x-1; 
						p.y := pos.y;
					END
					ELSE
					BEGIN
						p.x:= pos.x+1;
						p.y:= pos.y;
					END;
				END;
			
		
	END;	
	unVoisin := p;
END;




FUNCTION rules(g : grille; pos: position ):BOOLEAN ;
VAR  //temp : INTEGER;
	p : position;
BEGIN
		
		IF ((g[pos.x,pos.y-1].couleur + g[pos.x,pos.y+1].couleur + g[pos.x-1,pos.y].couleur + g[pos.x+1,pos.y].couleur < 2) AND  (g[pos.x,pos.y-1].couleur + g[pos.x,pos.y+1].couleur + g[pos.x-1,pos.y].couleur + g[pos.x+1,pos.y].couleur > 0))THEN
		BEGIN
			p := unVoisin(g ,pos);
			IF ((( (g[p.x,p.y].couleur = g[pos.x,pos.y].couleur) AND (g[p.x,p.y].forme <> g[pos.x,pos.y].forme)) OR ((g[p.x,p.y].couleur <> g[pos.x,pos.y].couleur) AND (g[p.x,p.y].forme = g[pos.x,pos.y].forme)))) THEN 
				rules := TRUE
			ELSE 
				rules := FALSE;
		END
		ELSE
		BEGIN
		END;
			
END;






END.
