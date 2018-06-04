PROGRAM test;
USES console    in 'uix/consoleUI/console.pas', crt, sysutils,
	constants  in 'core/constants.pas',
	structures in 'core/structure.pas',
	legal      in 'legal/legal.pas',
	game       in 'core/game.pas';

VAR
	pioche : typePioche;
	p ,p2 , p3, pTest: pion;
	i, y,l,v,b ,c,f	,s,n: INTEGER;
	g : grille;
	main : mainJoueur;
	ch : char;
	pos : position;
BEGIN
	writeln(ord(readKey()));
END.
