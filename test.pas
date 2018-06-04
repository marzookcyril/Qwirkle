PROGRAM test;
USES console    in 'uix/consoleUI/console.pas', crt, sysutils,
	constants  in 'core/constants.pas',
	structures in 'core/structure.pas',
	legal      in 'legal/legal.pas',
	game       in 'core/game.pas';

VAR
	pioche : typePioche;
	p ,p2 , p3, pTest: pion;
	i, y,l,v,b ,c,f	,s,n, points,pointss : INTEGER;
	g : grille;
	main : mainJoueur;
	ch : char;
	pos : position;
	t : tabPos;
BEGIN
	pTest.couleur := 0;
 	pTest.forme   := 0;
  	g := remplirGrille;
  	initConsole;
  	clrscr;
  	clearScreen(0);
  	renderMenuBorder;
  
 	//p.forme := FORME_ETOILE;
 	//p.couleur := COULEUR_VERT;
 	//ajouterPion(g, p, 8, 8, '');
 	p.forme := FORME_CROIX;
 	p.couleur := COULEUR_VERT;
 	ajouterPion(g, p, 8, 8, '');
  
 	{p.forme := FORME_LOSANGE;
 	p.forme := FORME_CARRE;
  	p.couleur := COULEUR_VERT;
 	ajouterPion(g, p, 7, 5, '');
 	ajouterPion(g, p, 6, 6, '');}
  
  	p.forme := FORME_CARRE;
	p.couleur := COULEUR_JAUNE;
 	ajouterPion(g, p, 6, 4, '');
 	
 	p.forme := FORME_CARRE;
 	p.couleur := COULEUR_ORANGE;
 	ajouterPion(g, p, 5, 7, '');
  
  	p.forme := FORME_ROND;
  	p.couleur := COULEUR_VERT;
  	ajouterPion(g, p, 7,6 , '');
  
 	//p.forme := FORME_CARRE;
 	//p.couleur := COULEUR_VIOLET;
 	//ajouterPion(g, p, 6, 3, '');
 	{p.forme := FORME_CARRE;
 	p.couleur := COULEUR_VIOLET;
 	ajouterPion(g, p, 9, 8, '');}
  
 	//p.forme := FORME_CARRE;
 	{p.forme := FORME_CARRE;
  	p.couleur := COULEUR_ROUGE;
 	ajouterPion(g, p, 8, 7, '');
 	ajouterPion(g, p, 8, 7, '');}
  
  	p.forme := FORME_CARRE;
  	p.couleur := COULEUR_BLEU;
  	ajouterPion(g, p, 6, 7, '');
  
 	
 	p.forme := FORME_CARRE;
 	p.couleur := COULEUR_VERT;
  	 
 	IF placer(g,7,7,p) THEN 
  	BEGIN
  		writeln('on peut placer');
 		ajouterPion(g,p,7,7,'');
 		t := initTabPos();
 		choperPos(t,7,7,1);
 		points := point(g,t,1);
 		writeln('le nombre de points est de ', points);
  	END
  	ELSE 
  		writeln('on peut pas placer');
  	
 
  		
 	writeln(concordanceGenerale(g, 7, 7, p));
 	writeln(duplicationPion(g, 7,7, p));
 	
 	//writeln(concordanceGenerale(g, 7, 7, p));
 	//writeln(duplicationPion(g, 7,7, p));
 	writeln('position de lautre pion ?');
 	readln(v,b);
 	writeln('couleur et forme du pion ?');
 	readln(c,f);
 	p2.couleur := c;
 	p2.forme := f;
 	IF nCoups(g,7,7,v,b,0,0,2,p,p2,pTest) THEN 
 	BEGIN
 		writeln('on peut placer');
 		ajouterPion(g,p2,v,b,'');
 		choperPos(t,v,b,2);
 		pointss := point(g,t,1);
 		writeln('le nombre de points est de ', pointss);
 	END
 	ELSE 
 		writeln('on peut pas placer');
 	writeln('position de lautre pion encore ?');
 	readln(s,n);
 	writeln('couleur et forme du pion ?');
 	readln(c,f);
 	p3.couleur := c;
 	p3.forme := f;
 	IF nCoups(g,7,7,v,b,s,n,3,p,p2,p3) THEN 
 	BEGIN
 		writeln('on peut placer');
 		ajouterPion(g,p3,s,n,'');
 	END
	ELSE 
		writeln('on peut pas placer');
  	{pioche := initPioche;
  	shufflePioche(pioche);
  	main := creerMain(pioche);
	writeln(ord(readKey()));}
END.
