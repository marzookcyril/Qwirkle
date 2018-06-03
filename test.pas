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
	ch : char;
	pos : position;
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

	shufflePioche(pioche);
	selectorPos(g);
	//main := creerMain(pioche);
	//pos := selectorPos(g);
	//selectorMain(main);
END.
