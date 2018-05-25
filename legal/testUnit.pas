PROGRAM testUnit;

USES legal, 
	 constants  in '../core/constants.pas', crt,
	 structures in '../core/structures.pas';
VAR
	g : grille;
	pos : position;
BEGIN
	g := remplirGrille(g);
	g[4,4].couleur := COULEUR_ROUGE;
	g[4,4].forme   := FORME_ROND;
	pos.x := 4;
	pos.y := 3;
	g[pos.x, pos.y].couleur := COULEUR_ROUGE;
	g[pos.x,pos.y].forme    := FORME_TREFLE;
	IF rules(g,pos) THEN 
		writeln('le pion peut etre placé donc test reussi')
	ELSE 
		writeln('test raté');
	
END.
