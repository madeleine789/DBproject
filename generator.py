from random import randint
import random
import time
import datetime
import argparse



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
nips = []

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

	return ulica + ', ' + miasto + ', ' + kod + ', ' + "\"" + 'Polska' + "\""


def generuj_firme():

	NIP = str(randint(10000,99999))
	while NIP in nips:
		NIP = str(randint(10000,99999))
	else:
		nips.append(NIP) 

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


def generuj_daty_konf(start,end,p):

    def daty_konf(start,end,format,p):

        konf_kalendarz = {}

        start_t = time.mktime(time.strptime(start,format))
        end_t = time.mktime(time.strptime(end,format))

        rand_st = start_t + p * (end_t - start_t)
        l_dni = random.sample(set([0,86400,172800]),1)
        rand_et = rand_st + float(l_dni[0])
        
        dni = []
        data = datetime.datetime.fromtimestamp(rand_st).date()
        while (data <= datetime.datetime.fromtimestamp(rand_et).date()):
            data_str = data.strftime('%m/%d/%Y')
            dni.append(data_str)
            data += datetime.timedelta(days=1)
            
        if (datetime.date.today() - datetime.datetime.fromtimestamp(rand_st).date()).days  >= 0:
            status = '4'
        elif (datetime.date.today() - datetime.datetime.fromtimestamp(rand_st).date()).days  > -7:
            status = '3'
        elif time.mktime(time.strptime(datetime.date.today().strftime('%m/%d/%Y'), '%m/%d/%Y')) - rand_et  > -90 :
            status = '1'
        else:
            status = '2'

        konf_kalendarz['lista_dni'] = dni
        konf_kalendarz['liczba_dni'] = 1 + int((rand_et - rand_st)/86400)
        konf_kalendarz['status'] = status

        return konf_kalendarz

    return daty_konf(start, end, '%m/%d/%Y', p)

def generuj_liste_klientow(N=500,prywatni=True):
	klienci_lista = []
	for i in xrange(N):
		klient = {}
		if prywatni:
			dane = generuj_osobe()
		else: 
			dane = generuj_firme()
		for key, val in dane.iteritems():
			klient[key] = dane[key]
		klient['adres'] = generuj_adres()
		klienci_lista.append(klient)

	return klienci_lista




def generuj_konferencja(lista_klientow_prywatnych,lista_klientow_firmy,id_konferencji,id_warsztatu,id_dnia,id_osoby,id_klienta,id_zamowienia,id_zamszczegolowego,id_zamwarsztatu):

	id_uczestnika = 1
	konferencja = {}
	id_os  = id_osoby
	id_kl = id_klienta
	id_tematu_konf = random.randint(1, len(tematy_konferencji))
	konf = generuj_daty_konf('1/1/2009', '3/1/2014',random.random())
	lista_dni = konf['lista_dni']
	liczba_dni = konf['liczba_dni']
	status = konf['status']
	cena = random.randint(300,700)	
	

	dni_konf = []
	limit_miejsc_k = 0
	for i in xrange(liczba_dni):
		dzien_konf = {}
		dzien_konf['id_konferencji'] = str(id_konferencji)
		dzien_konf['dzien_konferencji'] = "\"" + lista_dni[i] + "\""
		dzien_konf['limit_miejsc'] = str(random.randint(40,80))
		limit_miejsc_k += int(dzien_konf['limit_miejsc'])
		dzien_konf['id_dnia'] = id_dnia
		dzien_konf['warsztaty'] = []
		for i in xrange(4):
			warsztat = generuj_warsztat(id_dnia, id_warsztatu)
			dzien_konf['warsztaty'].append(warsztat)
			id_warsztatu +=1
		dni_konf.append(dzien_konf)
		id_dnia += 1
		
 	konferencja['id_konferencji'] = id_konferencji
 	konferencja['id_warsztatu'] = id_warsztatu
	konferencja['id_tematu_konf'] = str(id_tematu_konf)
	konferencja['data_rozp'] = "\"" + lista_dni[0] + "\""
	konferencja['data_zak'] =  "\"" + lista_dni[liczba_dni-1] + "\""
	konferencja['cena'] = str(cena)
	konferencja['status'] = status
	konferencja['lista_dni'] = dni_konf
	klienci = []


	for i in xrange(0,int(limit_miejsc_k/2)):
		klient = {}
		num = randint(0,len(lista_klientow_prywatnych)-1)
		k = lista_klientow_prywatnych[num]

		for key in k.keys():
			klient[key] = k[key]
		klient['id_klienta'] = id_kl
		klient['id_osoby']  = id_os
		klient['id_uczestnika'] = id_uczestnika
		klient['zamowienie'] = generuj_zamowienie(id_zamowienia, id_zamszczegolowego,id_zamwarsztatu,klient, konferencja, konferencja['lista_dni'])
		klienci.append(klient)



		id_uczestnika += 1
		id_zamowienia += 1
		id_zamszczegolowego += 1
		id_zamwarsztatu += 1
		id_kl += 1
		id_os += 1

	for i in xrange(0,int(limit_miejsc_k/8)):
		klient = {}
		num = randint(0,len(lista_klientow_firmy)-1)
		k = lista_klientow_firmy[num]	
		for key in k.keys():
			klient[key] = k[key]	
		klient['id_klienta'] = id_kl
		id_kl += 1 
		pracownicy = []
		for i in xrange(0,random.randint(1,4)):
			pracownik = {}
			dane = generuj_osobe()
			for key in dane.keys():
				pracownik[key] = dane[key]
			pracownik['id_osoby'] = str(id_os)
			pracownik['NIP'] = klient['NIP']
			pracownik['id_uczestnika'] = str(id_uczestnika)
			id_uczestnika += 1
			id_os += 1
			pracownicy.append(pracownik)
		klient['pracownicy'] = pracownicy
		klient['zamowienie'] = generuj_zamowienie(id_zamowienia, id_zamszczegolowego, id_zamwarsztatu, klient, konferencja, konferencja['lista_dni'])
		klienci.append(klient)
		id_zamowienia += 1
		id_zamszczegolowego += 1
		id_zamwarsztatu += 1

	
	konferencja['id_dnia'] = id_dnia
	konferencja['id_osoby'] = id_os
	konferencja['id_klienta'] = id_kl
	konferencja['id_zamowienia'] = id_zamowienia
	konferencja['id_zamszczegolowego'] = id_zamszczegolowego
	konferencja['klienci'] = klienci

	return konferencja


def generuj_konferencje(l_konferencji = 10):

	id_dnia = 1
	id_osoby = 1
	id_klienta = 1
	id_zamszczegolowego = 1
	id_zamowienia = 1
	id_warsztatu = 1
	id_zamwarsztatu = 1
	id_konferencji = 1

	lista_klientow_prywatnych = generuj_liste_klientow(200)
	lista_klientow_firmy = generuj_liste_klientow(100, prywatni = False)

	konferencje = []
	for i in xrange(0,l_konferencji):
		
		konferencja = generuj_konferencja(lista_klientow_prywatnych,lista_klientow_firmy,id_konferencji, id_warsztatu, id_dnia, id_osoby, id_klienta, id_zamowienia, id_zamszczegolowego, id_zamwarsztatu)
		
		id_konferencji += 1
		id_dnia = konferencja['id_dnia']
		konferencje.append(konferencja)
	
	return konferencje


def generuj_godziny(godz_rozp,format):
    
    delta_1 = random.randint(0,420)
    while delta_1 % 5 != 0: delta_1 = random.randint(0,420)
    delta_2 = random.sample(set([90,120,150]), 1)[0]
    godz_r = datetime.datetime.strptime(godz_rozp, format) + datetime.timedelta(minutes = delta_1)
    godz_z = godz_r + datetime.timedelta(minutes=delta_2)
    
    godziny = {}
    godziny['godz_rozp'] = "\"" + str(datetime.datetime.strftime(godz_r,format)) + "\""
    godziny['godz_zak'] = "\"" + str(datetime.datetime.strftime(godz_z,format)) + "\""
    godziny['czas_trw'] = delta_2
    
    return godziny


def generuj_warsztat(id_dnia, id_warsztatu):
	
	godziny = generuj_godziny("10:00:00", "%H:%M:%S")

	warsztat = {}
	warsztat['id_dnia'] = str(id_dnia)
	warsztat['id_tematu'] = str(random.randint(1, len(tematy_warsztatow)))
	warsztat['limit_miejsc'] = str(20)
	warsztat['godz_rozp'] = godziny['godz_rozp']
	warsztat['godz_zak'] = godziny['godz_zak']
	warsztat['id_warsztatu'] = id_warsztatu
	warsztat['uczestnicy'] = []

	if godziny['czas_trw'] == 90 : warsztat['cena'] = str(random.randint(100,200))
	elif godziny['czas_trw'] == 120 : warsztat['cena'] = str(random.randint(200,300))
	else: warsztat['cena'] = str(random.randint(300,400))

	return warsztat


def generuj_tematy_konferencji():

	tematy_konf = []
	for temat in tematy_konferencji:
		tematy_konf.append("\"" + temat + "\"")
	return tematy_konf


def generuj_tematy_warsztatow():
	
	tematy_warsz = []
	for temat in tematy_warsztatow:
		tematy_warsz.append("\"" + temat + "\"")
	return tematy_warsz		


def generuj_daty_zamowien(start, format):
    
    data_rozp = datetime.datetime.strptime(start, format)
    time_delta  = random.randint(20, 90)
    data_zlozenia_zam = data_rozp - datetime.timedelta(days=time_delta)
    termin_zaplaty = data_rozp - datetime.timedelta(days=7)  
    if time_delta <=30: procent_ceny = 1.10
    elif time_delta <=60: procent_ceny = 1.00
    else: procent_ceny = 0.9
         
    zam_kalendarz = {}
    zam_kalendarz['procent_ceny'] = procent_ceny
    zam_kalendarz['data_zlozenia_zam'] = datetime.datetime.strftime(data_zlozenia_zam,format)
    zam_kalendarz['termin_zaplaty'] = datetime.datetime.strftime(termin_zaplaty,format)
    
    return zam_kalendarz


def generuj_zamowienie(ID_Zamowienia,ID_ZamSzczegolowego,ID_ZamWarsztatu,klient,konferencja,lista_dni):
	
	daty = generuj_daty_zamowien(konferencja['data_rozp'].strip("\""), "%m/%d/%Y")
	zamowienie = {}
	id_zamszczegolowego =  ID_ZamSzczegolowego
	id_zamwarsztatu = ID_ZamWarsztatu
	zamowienie['id_zamowienia'] = str(ID_Zamowienia)
	zamowienie['id_klienta'] = klient['id_klienta']
	zamowienie['id_konferencji'] = konferencja['id_konferencji']
	print zamowienie['id_konferencji']
	zamowienie['data_zl_zam'] = daty['data_zlozenia_zam']
	zamowienie['termin_platnosci'] = daty['termin_zaplaty']
	zamowienie['do_zaplaty'] = int((daty['procent_ceny'] * int(konferencja['cena'])))
	#print zamowienie['do_zaplaty']
	do_z = int((daty['procent_ceny'] * int(konferencja['cena'])))
	if klient.has_key('pracownicy'): 
		do_z = int(do_z * len(klient['pracownicy']))
	zamowienie['zaplacono'] = do_z
	#print zamowienie['zaplacono']
	if zamowienie['zaplacono'] < zamowienie['do_zaplaty']: 
		zamowienie['status_platnosci'] = '1'
		zamowienie['status_rezerwacji'] = '1'
	else: 
		zamowienie['status_platnosci'] = '2'
		zamowienie['status_rezerwacji'] = '1'
	zamowienie['status_rejestracji'] = '2'



	zamowienie['zamowienia_szczegolowe'] = []
	for day in lista_dni:
		zam_szcz = {}
		zam_szcz['id_zamszczegolowego'] = str(id_zamszczegolowego)
		zam_szcz['id_zamowienia'] = str(zamowienie['id_zamowienia'])
		zam_szcz['id_dnia'] = str(day['id_dnia'])
		if klient.has_key('pracownicy'): zam_szcz['liczba_miejsc_konf'] = str(len(klient['pracownicy']))
		else: zam_szcz['liczba_miejsc_konf'] = str(1)
		zam_szcz['zamowienia_warsztatow'] = []

		for warsztat in day['warsztaty']:
			id_uczwarsztatu = 1
			zam_warszt = {}
			zam_warszt['id_zamszczegolowego'] = str(id_zamszczegolowego)
			zam_warszt['id_zamwarsztatu'] = str(id_zamwarsztatu)
			zam_warszt['id_warsztatu'] = str(warsztat['id_warsztatu'])
			if klient.has_key('pracownicy'): 
				zam_warszt['liczba_msc'] = len(klient['pracownicy'])
			else: zam_warszt['liczba_msc'] = str(1)
			zam_warszt['status_rezerwacji'] = zamowienie['status_rezerwacji']
			zam_szcz['zamowienia_warsztatow'].append(zam_warszt)
			id_zamwarsztatu +=1

		id_zamszczegolowego += 1
		zamowienie['zamowienia_szczegolowe'].append(zam_szcz)

	zamowienie['id_zamszczegolowego'] = id_zamszczegolowego
	zamowienie['id_zamwarsztatu'] = id_zamwarsztatu

	return zamowienie


def generuj_plik(filename, l_konf = 50):
    with open(filename, 'w') as f:

        for item in generuj_tematy_konferencji():
            f.write('EXEC dodaj_temat_konferencji ' + item + '\n')
        for item in generuj_tematy_warsztatow():
            f.write('EXEC dodaj_temat_warsztatu ' + item + '\n')
        
        for konf in generuj_konferencje(l_konf):
            
            f.write('EXEC dodaj_konferencje ' + konf['id_tematu_konf'] + ', ' + konf['data_rozp'] + ', ' + konf['data_zak'] + ', ' + konf['cena'] + ', ' + konf['status'] + '\n')
            
            l_dni = konf['lista_dni']
            for day in l_dni:
                f.write('EXEC dodaj_dzien_konferencji ' + day['id_konferencji'] + ', ' + day['dzien_konferencji'] + ', ' + day['limit_miejsc'] + '\n')
                l_warsztatow = day['warsztaty']
                for warszt in l_warsztatow:
                    f.write('EXEC dodaj_warsztat ' + warszt['id_tematu'] + ', ' + warszt['id_dnia'] + ', ' + warszt['cena'] + ', ' + warszt['limit_miejsc'] + ', ' + warszt['godz_rozp'] + ', ' + warszt['godz_zak'] + '\n')
            l_klientow = konf['klienci']
            
            for kl in l_klientow:
                if 'pracownicy' in kl:
                    f.write('EXEC dodaj_klienta_firma ' + kl['NIP'] + ', ' + kl['nazwa'] + ', ' + kl['telefon'] + ', ' + kl['fax'] + ', ' + kl['email'] + ', ' + kl['adres'] + '\n')
                    l_pracownikow = kl['pracownicy']
                    for prac in l_pracownikow:
                        f.write('EXEC dodaj_osobe ' + prac['imie'] + ', ' + prac['nazwisko'] + ', ' + prac['nr_albumu'] + ', ' + prac['telefon'] + ', ' + prac['email'] + '\n')
                        f.write('EXEC dodaj_pracownika ' + prac['NIP'] + ', ' + prac['id_osoby']+ '\n')
                        
                else:
                    f.write('EXEC dodaj_klienta_osoba ' + kl['imie'] + ', ' + kl['nazwisko'] + ', ' + kl['nr_albumu'] + ', ' + kl['telefon'] + ', ' + kl['email'] + ', ' + kl['adres'] + '\n')

                zam = kl['zamowienie']
                f.write('EXEC dodaj_zamowienie ' + str(zam['id_klienta']) + ', ' + str(zam['id_konferencji']) + ', ' + "\""+zam['data_zl_zam']+ "\""+ ', ' + zam['status_rejestracji'] + ', ' + str(zam['status_rezerwacji']) + ', ' +str(zam['do_zaplaty']) + ', ' + str(zam['zaplacono']) + ', ' + "\"" + zam['termin_platnosci'] + "\""+ ', ' + str(zam['status_platnosci']) + '\n' )
                for zam_s in zam['zamowienia_szczegolowe']:
                    f.write('EXEC dodaj_zamowienie_szcz ' + zam_s['id_zamowienia'] + ', ' + zam_s['id_dnia'] + ', ' + zam_s['liczba_miejsc_konf'] + '\n')
                    if 'imie' in kl:
                        f.write('EXEC dodaj_uczestnika_konferencji ' + str(kl['id_osoby']) + ', ' + str(zam_s['id_zamszczegolowego']) + '\n')
                    else:
                    	for prac in kl['pracownicy']:
                    	    f.write('EXEC dodaj_uczestnika_konferencji ' + prac['id_osoby'] + ', ' + zam_s['id_zamszczegolowego'] + '\n')
                    for zam_w in zam_s['zamowienia_warsztatow']:
                        f.write('EXEC dodaj_zamowienie_warsztatu ' + str(zam_w['id_zamszczegolowego']) + ', ' + str(zam_w['id_warsztatu']) + ', ' + str(zam_w['liczba_msc']) + ', ' + str(zam_w['status_rezerwacji']) + '\n')
                        
                

parser = argparse.ArgumentParser(description="")

parser.add_argument("-n", "--number", dest = "number", type=int, default=50,
                    help = "liczba konferencji - default = 50")
parser.add_argument("-f", "--file", dest="filename", type=str, default="data.sql",
					help = "nazwa pliku - default = data.sql")

if __name__ == "__main__":

	args = parser.parse_args()
	print generuj_plik(args.filename, args.number)




