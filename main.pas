PROGRAM main;
	
USES console in 'uix/consoleUI/console.pas', crt,
	 constants in 'core/constants.pas',
	 structures in 'core/structure.pas';

BEGIN
	clrscr;
	clearScreen(COL_BLACK);
	renderMenuBorder;
	renderGame;
	render;
END.

