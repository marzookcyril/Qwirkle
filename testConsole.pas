PROGRAM testConsole;

USES UIGraphic, structures, constants, game, crt, glib2d, SDL_TTF , sysutils;


VAR 
	i , j, taille, length : INTEGER;
    font : PTTF_Font;
    text_image : gImage;
    g : grille;
BEGIN
	g := remplirGrille;

    WHILE TRUE DO
    BEGIN
		gClear(WHITE);
		
		renderGrilleUI(g);
		
		gFlip();
		
        while (sdl_update = 1) do
			if (sdl_do_quit) then
				exit;

       
    END;
END.
