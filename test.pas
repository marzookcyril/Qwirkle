PROGRAM test;
USES console in 'uix/consoleUI/console.pas', crt, sysutils,
	constants in 'core/constants.pas',
	structures in 'core/structure.pas',
	legal in 'legal/legal.pas',
	game in 'core/game.pas';

VAR
	pioche : typePioche;
	p : pion;
	i, y,l,v,b : INTEGER;
	g : grille;
	main : mainJoueur;
BEGIN

	g := remplirGrille;
	initConsole;
	clrscr;
	clearScreen(0);
	renderMenuBorder;

	//p.forme := FORME_ETOILE;
	//p.couleur := COULEUR_VERT;
	//ajouterPion(g, p, 8, 8, '');

	{p.forme := FORME_LOSANGE;
	p.couleur := COULEUR_VERT;
	ajouterPion(g, p, 7, 5, '');

	p.forme := FORME_CARRE;
	p.couleur := COULEUR_JAUNE;
	ajouterPion(g, p, 6, 4, '');}

	p.forme := FORME_ROND;
	p.couleur := COULEUR_VERT;
	ajouterPion(g, p, 7,6 , '');

	//p.forme := FORME_CARRE;
	//p.couleur := COULEUR_VIOLET;
	//ajouterPion(g, p, 6, 3, '');

	p.forme := FORME_CARRE;
	p.couleur := COULEUR_ROUGE;
	ajouterPion(g, p, 8, 7, '');

	p.forme := FORME_CARRE;
	p.couleur := COULEUR_BLEU;
	ajouterPion(g, p, 6, 7, '');

	p.forme := FORME_ROND;
	p.couleur := COULEUR_ROUGE;
	
	IF placer(g,8,8,p) THEN 
	BEGIN
		writeln('on peut placer');
		ajouterPion(g,p,8,8,'');
	END
	ELSE 
		writeln('on peut pas placer');
	
		
	writeln(concordanceGenerale(g, 7, 7, p));
	writeln(duplicationPion(g, 7,7, p));
	
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
