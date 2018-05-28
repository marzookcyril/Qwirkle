UNIT legalPaul;
INTERFACE
USES structures in 'core/structures.pas',
     constants  in 'core/constants.pas';

FUNCTION isLegal(g : grille; x, y : INTEGER; p : pion) : BOOLEAN;

IMPLEMENTATION

     FUNCTION findDir(dir : INTEGER ) : position;
     VAR
          pos : position;
     BEGIN
          CASE dir OF
               1 : BEGIN
                    pos.x := -1;
                    pos.y := 0;
               END;
               2 : BEGIN
                    pos.x := 0;
                    pos.y := 1;
               END;
               3 : BEGIN
                    pos.x := 1;
                    pos.y := 0;
               END;
               4 : BEGIN
                    pos.x := 0;
                    pos.y := -1;
               END;
          END;
          findDir := pos;
     END;

     // dir :     2
     //         1 + 3
     //           4
     FUNCTION respectCouleur(g : grille; pos : position; dir : INTEGER) : BOOLEAN;
     VAR
          i : INTEGER;
          dirValue : position;
     BEGIN
          dirValue := findDir(dir);
          i := 1;
          WHILE (i <= 5) OR (g[pos.x + i * dirValue.x, pos.y + i * dirValue.y].couleur = COULEUR_NULL) DO
          BEGIN
               IF (g[pos.x + i * dirValue.x, pos.y + i * dirValue.y].couleur <> g[pos.x + 1 * dirValue.x, pos.y + 1 * dirValue.y].couleur) AND (g[pos.x + i * dirValue.x, pos.y + i * dirValue.y].couleur <> COULEUR_NULL) THEN
                    i := 10
               ELSE
                    inc(i);
          END;
          respectCouleur := (i <= 6);
     END;

     FUNCTION respectForme(g : grille; pos : position; dir : INTEGER) : BOOLEAN;
     VAR
          i : INTEGER;
          dirValue : position;
     BEGIN
          dirValue := findDir(dir);
          i := 1;
          WHILE (i <= 5) OR (g[pos.x + i * dirValue.x, pos.y + i * dirValue.y].forme = FORME_NULL) DO
          BEGIN
               IF (g[pos.x + i * dirValue.x, pos.y + i * dirValue.y].forme <> g[pos.x + 1 * dirValue.x, pos.y + 1 * dirValue.y].forme) AND (g[pos.x + i * dirValue.x, pos.y + i * dirValue.y].forme <> FORME_NULL) THEN
                    i := 10
               ELSE
                    inc(i);
          END;
          respectForme := (i <= 6);
     END;

     // trouve le paterne des voisins
     FUNCTION findPaterne(g : grille; pos : position) : STRING;
     VAR
          final : STRING;
          i : INTEGER;
     BEGIN
          final := '';
          // on commence par la gauche
          FOR i := 1 TO 4 DO
          BEGIN
               IF respectCouleur(g, pos, i) THEN
                    final := final + 'C'
               ELSE
               BEGIN
                    IF respectForme(g, pos, i) THEN
                         final := final + 'F'
                    ELSE
                         final := final + '0';
               END;
          END;
          findPaterne := final;
     END;

     FUNCTION isLegal(g : grille; x, y : INTEGER; p : pion) : BOOLEAN;
     VAR
          paterne : STRING;
          dir : position;
          i : INTEGER;
          erreur : BOOLEAN;
     BEGIN
          dir.x := x;
          dir.y := y;
          paterne := findPaterne(g, dir);
          erreur := FALSE;

          WriteLn('paterne OK');
          FOR i := 0 TO 3 DO
          BEGIN
               dir := findDir(i);
               CASE paterne[i] OF
                    'C' : BEGIN
                              IF (p.couleur <> g[x + dir.x, y + dir.y].couleur) AND (g[x + dir.x, y + dir.y].couleur <> COULEUR_NULL) THEN
                                   erreur := TRUE;
                          END;
                    'F' : BEGIN
                              IF (p.forme <> g[x + dir.x, y + dir.y].forme) AND (g[x + dir.x, y + dir.y].forme <> FORME_NULL) THEN
                                   erreur := TRUE;
                          END;
               END;
          END;
     END;
END.
