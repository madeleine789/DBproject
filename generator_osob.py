from random import randint
import random



imiona_meskie = [line.strip() for line in open('im_m.txt')]
imiona_zenskie = [line.strip() for line in open('im_z.txt')]
nazwiska = [line.strip() for line in open('lol.txt')]
ulice = [line.strip() for line in open('ulice.txt')]
miasta = [line.strip() for line in open('miasta.txt')]
miasta_kody = {}
for i in miasta:
	miasto, kod = i.split(' ')
	miasta_kody[miasto] = kod

def generuj_dane():

	if (randint(0,100) % 2 == 0 ):
		imie = "\"" + imiona_zenskie[randint(0,len(imiona_zenskie)-1)] +  "\""
	else:
		imie = "\"" + imiona_meskie[randint(0,len(imiona_meskie)-1)] + "\""

	if (randint(0,100) % 13 == 0) :
		nr_albumu = "\"" + str(randint(100000,999999)) + "\""
	else:
		nr_albumu = 'NULL'

	nazwisko = "\"" + nazwiska[randint(0,len(nazwiska)-1)] + "\""

	telefon = "\"" + str(randint(100000000,999999999)) +  "\""

	email = "\"" + imie[1].lower() + str(nazwisko.lower().strip('\"')) + '@jestemailem.pl' + "\""

	return str(imie) + ', ' + str(nazwisko) + ', ' + str(nr_albumu) + ', ' + str(telefon) + ', ' + str(email)

def generuj_adres():
	
	adres = "\"" + ulice[randint(0,len(ulice)-1)] + ' ' + str(randint(1,200)) + "\""
	
	m_k = random.sample(miasta_kody.items(),1)
	for item in m_k:
		miasto = "\"" + str(item[0]) + "\""
		kod = "\"" + str(item[1]) + "\""

	return adres + ', ' + miasto + ', ' + kod + ', ' + "\"" + 'Polska' + "\""


def generuj_osoby():
	osoby =[]
	for i in xrange(0,7000):
		osoby.append(generuj_dane() + ', ' + generuj_adres())

	return osoby


def generuj_plik(filename):
	with open(filename, 'w') as f:
		for item in generuj_osoby():
			f.write ('EXEC dodaj_klienta_prywatnego ' + item + '\n')


print generuj_adres()
generuj_plik('klienci.sql')






