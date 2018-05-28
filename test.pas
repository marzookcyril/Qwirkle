PROGRAM test;
USES console in 'uix/consoleUI/console.pas', crt, sysutils,
	constants in 'core/constants.pas',
	structures in 'core/structure.pas',
	legalPaul in 'legal/legalPaul.pas',
	game in 'core/game.pas';

VAR
	pioche : typePioche;
	p : pion;
	i, y : INTEGER;
	g : grille;
BEGIN

	g := remplirGrille;
	initConsole;
	clrscr;
	clearScreen(0);
	renderMenuBorder;
	p.forme := FORME_ETOILE;
	p.couleur := COULEUR_BLEU;
	ajouterPion(g, p, 5, 5, '');
	p.forme := FORME_ROND;
	p.couleur := COULEUR_BLEU;
	ajouterPion(g, p, 7, 5, '');
	p.forme := FORME_CARRE;
	p.couleur := COULEUR_JAUNE;
	ajouterPion(g, p, 6, 4, '');
	p.forme := FORME_CARRE;
	p.couleur := COULEUR_ROUGE;
	ajouterPion(g, p, 6, 6, '');
	p.forme := FORME_CARRE;
	p.couleur := COULEUR_BLEU;
	writeln('je suis la');
	writeln(isLegal(g, 6, 5, p));

	{
	pioche := initPioche;
	shufflePioche(pioche);
	writeln('PIOCHE NON MELANGEE:');
	FOR i := 0 TO 107 DO
	BEGIN
		ajouterPion(g, pioche[i], i MOD 24, i DIV 24, inttostr(pioche[i].couleur));
		WriteLn(pioche[i].couleur);
	END;
	renderGame(g);
	render;
	}
END.
