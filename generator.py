from random import randint
import random
import time
import datetime


imiona_meskie = [line.strip() for line in open('im_m.txt')]
imiona_zenskie = [line.strip() for line in open('im_z.txt')]
nazwiska = [line.strip() for line in open('nazw.txt')]
firmy = [line.strip() for line in open('firmy.txt')]
ulice = [line.strip() for line in open('ulice.txt')]
miasta = [line.strip() for line in open('miasta.txt')]
miasta_kody = {}
for i in miasta:
	miasto, kod = i.split(' ')
	miasta_kody[miasto] = kod
tematy_konferencji = [line.strip() for line in open('tematy_k.txt')]
tematy_warsztatow = [line.strip() for line in open('tematy_w.txt')]


def generuj_adres():
	
	ulica = "\"" + ulice[randint(0,len(ulice)-1)] + ' ' + str(randint(1,200)) + "\""
	m_k = random.sample(miasta_kody.items(),1)
	for item in m_k:
		miasto = "\"" + str(item[0]) + "\""
		kod = "\"" + str(item[1]) + "\""

	adres = {}
	adres['ulica'] = ulica
	adres['miasto'] = miasto
	adres['kod'] = kod
	adres['kraj'] = '\"Polska\"'

	return adres
	#return ulica + ', ' + miasto + ', ' + kod + ', ' + "\"" + 'Polska' + "\""

def generuj_daty_konf(start,end,p):

    def daty_konf(start,end,format,p):

        dict_kalendarz = {}

        start_t = time.mktime(time.strptime(start,format))
        end_t = time.mktime(time.strptime(end,format))

        rand_st = start_t + p * (end_t - start_t)
        l_dni = random.sample(set([0,86400,172800]),1)
        rand_et = rand_st + float(l_dni[0])
        
        days = []
        date = datetime.datetime.fromtimestamp(rand_st).date()
        while (date <= datetime.datetime.fromtimestamp(rand_et).date()):
            date_str = date.strftime('%m/%d/%Y')
            days.append(date_str)
            date += datetime.timedelta(days=1)
            
        if (datetime.date.today() - datetime.datetime.fromtimestamp(rand_st).date()).days  >= 0:
            status = '\"skompletowany\"'
        elif (datetime.date.today() - datetime.datetime.fromtimestamp(rand_st).date()).days  > -7:
            status = '\"zakonczony\"'
        elif time.mktime(time.strptime(datetime.date.today().strftime('%m/%d/%Y'), '%m/%d/%Y')) - rand_et  > -90 :
            status = '\"w trakcie\"'
        else:
            status = '\"zamkniety\"'

        dict_kalendarz['lista_dni'] = days
        dict_kalendarz['liczba_dni'] = 1 + int((rand_et - rand_st)/86400)
        dict_kalendarz['status'] = status

        return dict_kalendarz

    return daty_konf(start, end, '%m/%d/%Y', p)



def generuj_osobe():

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

	osoba = {}
	osoba['imie'] = imie
	osoba['nazwisko'] = nazwisko
	osoba['nr_albumu']  = nr_albumu
	osoba['telefon'] = telefon
	osoba['email'] = email

	#return str(imie) + ', ' + str(nazwisko) + ', ' + str(nr_albumu) + ', ' + str(telefon) + ', ' + str(email)
	return osoba



def generuj_firme():

	NIP = str(randint(1000000000,9999999999)) + str(randint(1000000000,9999999999))
	nazwa = "\"" + firmy[randint(0,len(firmy)-1)] + "\""
	telefon = "\"" + str(randint(100000000,999999999)) +  "\""
	fax = "\"" + str(randint(100000000,999999999)) +  "\""
	email = "\"" + str(nazwa[0:6].lower().strip('\"')) + '@jestemailem.pl' + "\""
	#return str(NIP) + ', ' + str(nazwa) + ', ' + str(telefon) + ', ' + str(fax) + ', ' + str(email)
	firma = {}
	firma['NIP'] = NIP
	firma['nazwa'] = nazwa
	firma['telefon'] = telefon
	firma['fax'] = fax
	firma['email'] = email

	return firma


def generuj_firmy():
	pass


def generuj_konferencja(id_konferencji, id_dnia):

	id_tematu = random.randint(1, len(tematy_konferencji))
	konf = generuj_daty_konf('1/1/2009', '3/1/2014',random.random())
	lista_dni = konf['lista_dni']
	liczba_dni = konf['liczba_dni']
	status = konf['status']
	cena = 300

	if liczba_dni == 1:
		cena = random.randint(300,700)	
	elif liczba_dni == 2:
		cena = random.randint(600,1200)
	elif liczba_dni == 3:
		cena = random.randint(900,1800)

	dni_konf = []
	for i in xrange(liczba_dni):
		dzien_konf = {}
		dzien_konf['id_konferencji'] = str(id_konferencji)
		dzien_konf['dzien_konferencji'] = "\"" + lista_dni[i] + "\""
		dzien_konf['limit_miejsc'] = str(random.randint(40,80))
		dni_konf.append(dzien_konf)
		id_dnia += 1

	konferencja ={}
	konferencja['id_tematu'] = str(id_tematu)
	konferencja['data_rozp'] = "\"" + lista_dni[0] + "\""
	konferencja['data_zak'] =  "\"" + lista_dni[liczba_dni-1] + "\""
	konferencja['cena'] = str(cena)
	konferencja['status'] = status
	konferencja['lista_dni'] = dni_konf
	konferencja['id_dnia'] = id_dnia

	return konferencja
	#return id_tematu + ', ' + data_rozp + ', ' + data_zak + ', ' + "\"" + str(cena) + "\"" + ', ' + status

def generuj_konferencje():

	id_dnia = 1
	konferencje = []
	for i in xrange(1,73):
		id_konferencji = i
		konferencja = generuj_konferencja(id_konferencji,id_dnia)
		id_dnia = konferencja['id_dnia']
		konferencje.append(konferencja)
		print id_dnia
	
	return konferencje


def generuj_tematy_konferencji():

	t_konf = []
	for temat in tematy_konferencji:
		t_konf.append("\"" + temat + "\"")
	return t_konf

def generuj_tematy_warsztatow():
	t_warsz = []
	for temat in tematy_warsztatow:
		t_warsz.append("\"" + temat + "\"")
	return t_warsz


def generuj_plik(filename):
	with open(filename, 'w') as f:
		for item in generuj_konferencje():
				f.write('EXEC dodaj_konferencje ' + item['id_tematu'] + ', ' + item['data_rozp'] + ', ' + item['data_zak'] + ', ' + item['cena'] + ', ' + item['status']  + '\n')
				l = item['lista_dni']
				for i in xrange(len(l)):
					day = l[i]
					f.write('EXEC dodaj_dzien_konferencji ' + day['id_konferencji'] + ', ' + day['dzien_konferencji'] + ', ' + day['limit_miejsc'] + '\n')	 
		for item in generuj_tematy_konferencji():
			f.write('EXEC dodaj_temat_konferencji ' + item + '\n')
		for item in generuj_tematy_warsztatow():
			f.write('EXEC dodaj_temat_warsztatu ' + item + '\n')


#print generuj_osobe()
#print generuj_firme()

#generuj_plik('cos3.sql')

#print generuj_konferencja(2,1)
#print generuj_daty_konf('1/1/2009', '3/1/2014',random.random())

#print '\n'
#print generuj_konferencje()


