UNIT pAI;
INTERFACE
CONST

TYPE
	typePossibleMoves = RECORD
		pos  : position;
		etat : STRING;
	END;
	tabEtat          : ARRAY OF STRING;
	tabPossibleMoves : ARRAY OF possibleMoves;

IMPLEMENTATION
	FUNCTION findGlobalEtat(etat : STRING) : STRING;
	BEGIN
		IF
	END;

	FUNCTION findAllPosibleMove(g : grille; main : mainJoueur) : tabPossibleMoves;
	VAR
		x, y, i : INTEGER;
		tmpEtat : STRING;
		stop    : BOOLEAN;
		tmpPos  : position;
		tmpTabEtat : tabEtat;
		possibleMove : typePossibleMoves;
	BEGIN
		setLength(tabPossibleMoves, 0);
		setLength(tmpTabEtat, 40);
		FOR x := 0 TO TAILLE_GRILLE - 1 DO
		BEGIN
			FOR y := 0 TO TAILLE_GRILLE - 1 DO
			BEGIN
				tmpGlobalEtat := '';
				i := 0;
				WHILE i < 4 AND NOT stop DO
				BEGIN
					tmpEtat := findEtat(g, x, y, i + 1);
					IF tmpEtat = '404' THEN
						stop := TRUE
					ELSE
					BEGIN
						tmpTabEtat[i] := tmpEtat;
						inc(i);
					END
				END;
				tmpEtat := findGlobalEtat(tmpTabEtat);
				IF tmpEtat <> 'NULL' THEN
				BEGIN
					setLength(tabPossibleMoves, length(tabPossibleMoves) + 1);
					possibleMove.pos.x := x;
					possibleMove.pos.y := y;
					possibleMove.pos.etat := tmpEtat;
					tabPossibleMoves[length(tabPossibleMoves)] := possibleMove;
				END;
			END;
		END;
	END;
END.
