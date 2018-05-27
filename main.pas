PROGRAM main;

USES console in 'uix/consoleUI/console.pas', crt,
	constants in 'core/constants.pas',
	structures in 'core/structure.pas',
	game in 'core/game.pas';

VAR
	pionTest : pion;
	g : grille;
BEGIN
	g := remplirGrille;
	pionTest.couleur := COULEUR_ROUGE;
	pionTest.forme   := FORME_TREFLE;
	clrscr;
	clearScreen(COL_BLACK);
	renderMenuBorder;
	ajouterPion(g, pionTest, 1,1);
	ajouterPion(g, pionTest, 1,4);
	ajouterPion(g, pionTest, 1,6);
END.
