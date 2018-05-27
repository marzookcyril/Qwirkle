PROGRAM main;

USES console in 'uix/consoleUI/console.pas', crt,
	constants in 'core/constants.pas',
	structures in 'core/structure.pas',
	game in 'core/game.pas';

VAR
	pionTest : pion;
	g : grille;
	i : INTEGER;
BEGIN
	initConsole;
	g := remplirGrille;
	pionTest.couleur := COULEUR_ROUGE;
	pionTest.forme   := FORME_TREFLE;
	clrscr;
	clearScreen(COL_BLACK);
	renderMenuBorder;
	FOR i := 0 TO 10 DO
	BEGIN
		ajouterPion(g, pionTest, i, i, 'J1');
	END;
END.
