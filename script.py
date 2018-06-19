formes = ('Rond', 'Trefle', 'Etoile', 'Tache', 'Carre', 'Losange')
couleurs = ('b', 'vert', 'b', 'r', 'v', 'o')

final = ''

for col in couleurs:
	for forme in formes:
		final += '\'' + col + forme + '.png\',' 
		
print (final)
