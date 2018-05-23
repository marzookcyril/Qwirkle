PROGRAM main;
	
USES console in 'uix/consoleUI/console.pas', crt,
	 constants in 'core/constants.pas';

VAR
	i : INTEGER;
BEGIN
	clrscr;
	clearScreen(COL_BLACK);
	renderMenuBorder;
	renderGame;
	render;
END.

