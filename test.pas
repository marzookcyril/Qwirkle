PROGRAM test;
USES console in 'uix/consoleUI/console.pas', crt, sysutils,
	constants in 'core/constants.pas',
	structures in 'core/structure.pas',
	legal in 'legal/legal.pas',
	game in 'core/game.pas';

VAR
	pioche : typePioche;
	p ,p2 , p3, pTest: pion;
	i, y,l,v,b ,c,f	,s,n: INTEGER;
	g : grille;
	main : mainJoueur;
BEGIN
	pTest.couleur := 0;
	pTest.forme   := 0;
	g := remplirGrille;
	initConsole;
	clrscr;
	clearScreen(0);
	renderMenuBorder;

	p.forme := FORME_CROIX;
	p.couleur := COULEUR_VERT;
	ajouterPion(g, p, 8, 8, '');

	{p.forme := FORME_CARRE;
	p.couleur := COULEUR_VERT;
	ajouterPion(g, p, 6, 6, '');}

	p.forme := FORME_CARRE;
	p.couleur := COULEUR_ORANGE;
	ajouterPion(g, p, 5, 7, '');

	p.forme := FORME_ROND;
	p.couleur := COULEUR_VERT;
	ajouterPion(g, p, 7,6 , '');

	{p.forme := FORME_CARRE;
	p.couleur := COULEUR_VIOLET;
	ajouterPion(g, p, 9, 8, '');}

	{p.forme := FORME_CARRE;
	p.couleur := COULEUR_ROUGE;
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
	END
	ELSE 
		writeln('on peut pas placer');
	

		
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
	afficheMain(g,1,24,main);
	writeln('quel pion de votre main voulez vous placer?');
	readln(l);
	writeln('en quel position?');
	readln(v,b);
	IF  placer(g,v,b,main[l-1]) THEN 
		ajouterPion(g,main[l-1],23,1,'')
	ELSE
		writeln('ne peut pas etre placer');}
	//writeln('PIOCHE NON MELANGEE:');
	{FOR i := 0 TO 107 DO
	BEGIN
		ajouterPion(g, pioche[i], i MOD 24, i DIV 24, inttostr(pioche[i].couleur));
		WriteLn(pioche[i].couleur);
	END;}
	
	//render;
	
END.
