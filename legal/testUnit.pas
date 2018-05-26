PROGRAM testUnit;

USES legal, 
	 constants  in '../core/constants.pas', crt,sysutils,
	 structures in '../core/structures.pas';
VAR
	g : grille;
	pos : position;
BEGIN
	g := remplirGrille(g);
	g[4,4].couleur := COULEUR_ROUGE;
	g[4,4].forme   := FORME_ROND;
	g[4,5].couleur := COULEUR_ROUGE;
	g[4,5].forme   := FORME_ETOILE;
	pos.x := 4;
	pos.y := 3;
	g[pos.x, pos.y].couleur := COULEUR_ROUGE;
	g[pos.x,pos.y].forme    := FORME_ETOILE;
	IF not rules(g,pos) THEN 
	BEGIN
		TextColor(green);
		writeln('test reussi')
	END
	ELSE 
	BEGIN
		TextColor(red);
		writeln('test raté');
	END;
	g[pos.x, pos.y].couleur := COULEUR_VERT;
	g[pos.x,pos.y].forme    := FORME_CROIX;
	IF  rules(g,pos) THEN 
	BEGIN
		TextColor(red);
		writeln('test raté');
	END
	ELSE 
	BEGIN
		TextColor(green);
		writeln('test reussi');
	END;
	g[pos.x, pos.y].couleur := COULEUR_BLEU;
	g[pos.x,pos.y].forme    := FORME_CARRE;
	IF  rules(g,pos) THEN 
	BEGIN
		TextColor(red);
		writeln(' test raté');
	END
	ELSE 
	BEGIN
		TextColor(green);
		writeln('test reussi');
	END;
	g[pos.x, pos.y].couleur := COULEUR_ROUGE;
	g[pos.x,pos.y].forme    := FORME_CARRE;
	IF  rules(g,pos) THEN 
	BEGIN
		TextColor(green);
		writeln('test reussi');
	END
	ELSE 
	BEGIN
		TextColor(red);
		writeln('test raté')
	END;
	g[pos.x, pos.y].couleur := COULEUR_ROUGE;
	g[pos.x,pos.y].forme    := FORME_ETOILE;
	IF  NOT rules(g,pos) THEN 
	BEGIN
		TextColor(green);
		writeln('test reussi');
	END
	ELSE 
	BEGIN
		TextColor(red);
		writeln('test raté')
	END;
	TextColor(black);

	
	
END.
