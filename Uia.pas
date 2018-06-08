UNIT Uia;


INTERFACE 

USES structures , legal, game;

FUNCTION copierGrille(g : grille): grille ;
FUNCTION SimilariteMainCouleur( m : mainJoueur ; num : INTEGER) : mainJoueur;
FUNCTION SimilariteMainForme( m : mainJoueur; num : INTEGER) : mainJoueur;
FUNCTION compterPion(g: grille ; p : pion) : meilleurPion;
FUNCTION pionMain(g : grille ; m : mainJoueur) : meilleurPion;
FUNCTION compterCaseVide(g: grille):INTEGER;




IMPLEMENTATION

FUNCTION compterCaseVide(g: grille):INTEGER;
VAR i,j , k : INTEGER;
BEGIN
	k :=0;
	FOR i := 1 TO 23 DO
	BEGIN
		FOR j := 1 TO 23 DO 
		BEGIN
			IF g[i,j].forme = 0 THEN 
				inc(k);
		END;
	END;
	compterCaseVide := k;
END;




FUNCTION copierGrille(g : grille): grille ;
VAR gr : grille;
	i,j : INTEGER;
BEGIN
	FOR i := 0 TO 24 DO 
	BEGIN
		FOR j := 0 TO 24 DO 
		BEGIN
			gr[i,j]:= g[i,j];
		END;
	END;
	copierGrille := gr;
END;



FUNCTION SimilariteMainCouleur( m : mainJoueur ; num : INTEGER) : mainJoueur;
VAR similariteCouleur      : mainJoueur;	
	i , k   , taille       : INTEGER;
BEGIN
	k :=1;
	taille := 1;
	FOR i := 1 TO length(m)-1 DO 
	BEGIN
		IF ((m[num].couleur = m[i].couleur) AND (m[num].forme <> m[i].forme)) THEN 
			inc(taille);
	END;
	setlength(similariteCouleur,taille);
	similariteCouleur[0] := m[num];
	IF taille >1 THEN 
	BEGIN
		FOR i := num+1 TO length(m)-1  DO 
		BEGIN
			IF ((m[num].couleur = m[i].couleur) AND (m[num].forme <> m[i].forme)) THEN 
			BEGIN
				similariteCouleur[k] := m[i];
				inc(k);
			END;
		END;
		IF num >= 1 THEN 
		BEGIN
			FOR i := 0 TO num-1 DO 
			BEGIN
				IF ((m[num].couleur = m[i].couleur) AND (m[num].forme <> m[i].forme)) THEN 
				BEGIN
					similariteCouleur[k] := m[i];
					inc(k);
				END;
			END;
		END;
	END;
	SimilariteMainCouleur := similariteCouleur;
END;





FUNCTION SimilariteMainForme( m : mainJoueur; num : INTEGER) : mainJoueur;
VAR similariteForme : mainJoueur;
	i , k     , taille         : INTEGER;
BEGIN
	k :=1;
	taille := 1;
	FOR i := 1 TO length(m)-1 DO 
	BEGIN
		IF ((m[num].forme = m[i].forme) AND (m[num].couleur <> m[i].couleur)) THEN 
			inc(taille);
	END;
	setlength(similariteForme,taille);
	similariteForme[0] := m[num];
	IF taille >1 THEN 
	BEGIN
		FOR i := num+1 TO length(m)-1  DO 
		BEGIN
			IF ((m[num].forme = m[i].forme) AND (m[num].couleur <> m[i].couleur)) THEN 	
			BEGIN
				similariteForme[k] := m[i];
				inc(k);
			END;
		END;
		IF num >= 1 THEN 
		BEGIN
			FOR i := 0 TO num-1 DO 
			BEGIN
				IF ((m[num].forme = m[i].forme) AND (m[num].couleur <> m[i].couleur)) THEN	
				BEGIN
					similariteForme[k] := m[i];
					inc(k);
				END;
			END;
		END;
	END;
	SimilariteMainForme := similariteForme;
END;


FUNCTION compterPion(g: grille ; p : pion) : meilleurPion;
VAR 
	i, j  : INTEGER;
	mp    : meilleurPion;
	t     : tabPos;
	g1 : grille;
BEGIN
	writeln('je suis dans compterpion');
	mp.x     :=0;
	mp.y     :=0;
	mp.point :=0;
	mp.p     :=p;
	g1 := copierGrille(g);
	
	FOR i := 1 TO 23 DO 
	BEGIN
		FOR j := 1 TO 23 DO 
		BEGIN
			IF ((g[i,j].forme = 0) AND (calculVoisinShlag(g1,i,j,mp.p) <> 0) AND (placer(g1,i,j,mp.p))) THEN 
			BEGIN
				writeln(i,', ',j);
				IF placer(g1,i,j,mp.p) THEN
				BEGIN
					ajouterPion(g1,mp.p,mp.x,mp.y,'IA');
					t := initTabPos();
					choperPos(t,i,j,1);
					IF mp.point <= point(g1,t,1) THEN 
					BEGIN
						mp.x     := i;
						mp.y     := j;
						mp.point := point(g1,t,1);	
					END;
				ajouterPion(g1,PION_NULL,mp.x,mp.y,'IA');
				END;
			END;
		END;
	END;
	compterPion := mp;

END;

FUNCTION pionMain(g : grille ; m : mainJoueur) : meilleurPion;
VAR i ,k: INTEGER;
	mp , mpp   : meilleurPion;
	g1 : grille;
BEGIN
	k        := compterCaseVide(g);
	mp.x     :=0;
	mp.y     :=0;
	mp.point :=0;
	g1 := copierGrille(g);
	FOR i := 0 TO 5 DO 
	BEGIN	
		writeln('je suis dans pionMAin');
		writeln('pion numéro',i);
		IF (k <> 529 ) THEN 
		BEGIN
			mpp := compterPion(g1,m[i]);
			IF mp.point < mpp.point THEN 
			BEGIN
				mp.x     := mpp.x;
				mp.y     := mpp.y;
				mp.point := mpp.point;
				mp.p     := mpp.p;
			END;
		END;
	END;
	pionMain := mp;
END;


{FUNCTION  combinaison(g : grille ; m : mainJoueur): tabDyn;
VAR tcouleur : mainJoueur;
	tforme : mainJoueur;
	i : INTEGER;
BEGIN
	FOR i := 0 TO 5 DO 
	BEGIN
		tcouleur := SimilariteMainCouleur(m,i);
		tforme   := SimilariteMainForme(m,i);
	END;
		
END;

FUNCTION  sousCombinaison(g : grille ; t : mainJoueur): ;
VAR k : INTEGER;
	mp : meilleurPion;
	tabpion : tabPion;
	num , k : INTEGER;
BEGIN
	num := 2;
	setlength(tabpos,length(t)); 
	IF length(t) = 1 THEN 
		points := pionMain(g,t);
	ELSE 
	BEGIN
		tabpion := t
		FOR k := 0 TO length(t)-2 DO 
		BEGIN
			mp := compterPion(g,t[k]);
			g[mp.x,mp.y] := t[k];
			FOR i := k+1 TO length(t) -2 DO 
			BEGIN
				mpp := compterPion(g,t[i]);
				IF nCoups(g,tabpos,tabpion,num) THEN 
					g[mpp.x, mpp.y] := t[i]
			
				
		END;
	
	END;
END;

FUNCTION compteCombinaison(g : grille ; ):;
VAR 
BEGIN
	



END;}


END.
