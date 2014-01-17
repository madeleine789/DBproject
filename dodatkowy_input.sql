USE Konferencje
GO

--EXEC dodaj_temat_warsztatu "COBOL"
--EXEC dodaj_temat_konferencji "Abibliophobia"

--EXEC dodaj_konferencje 1, '05/05/2014', '05/05/2014', 150, 1
--EXEC dodaj_konferencje 1, '05/11/2014', '05/11/2014', 200, 1
--EXEC dodaj_konferencje 1, '06/01/2014', '06/02/2014', 300, 1
--EXEC dodaj_konferencje 1, '03/13/2014', '03/13/2014', 210, 1
--EXEC dodaj_konferencje 1, '09/09/2014', '09/09/2014', 210, 1

--SELECT * FROM Konferencja WHERE YEAR(DataRozpoczecia) LIKE '2014'

--EXEC dodaj_dzien_konferencji 1, '05/05/2014', 50
--EXEC dodaj_dzien_konferencji 2, '05/11/2014', 100
--EXEC dodaj_dzien_konferencji 3, '06/01/2014', 20
--EXEC dodaj_dzien_konferencji 3, '06/02/2014', 40
--EXEC dodaj_dzien_konferencji 4, '03/13/2014', 120
--EXEC dodaj_dzien_konferencji 5, '09/09/2014',1

--SELECT * FROM DzienKonferencji WHERE YEAR(DzienKonferencji) LIKE '2014'

--EXEC dodaj_warsztat 1, 6, 11, 2, '11:30:00', '14:30:00'
--EXEC dodaj_warsztat 1, 6, 40, 1, '12:00:00', '15:00:00'
--EXEC dodaj_warsztat 1, 6, 50, 1, '11:00:00', '12:00:00'
--EXEC dodaj_warsztat 32, 107, 20, 20, '14:30:00', '15:30:00'
--EXEC dodaj_warsztat 45, 108, 10, 20, '16:35:00', '19:35:00'
--EXEC dodaj_warsztat 46, 109, 100, 20, '12:35:00', '15:05:00'
--EXEC dodaj_warsztat 3, 105, 110, 20, '12:00:00', '15:00:00'

--SELECT * FROM Warsztat
--SELECT * FROM Osoba
--SELECT * FROM Klient

--EXEC dodaj_klienta_osoba "Julian", "Zak", NULL, "873938701", "jzak@jestemailem.pl", "Slupska 156", "Szczecin", "70-233", "Polska"
--EXEC dodaj_zamowienie 1, 5, "07/12/2012", 2, 1, 580, 580, "07/30/2012", 2
--EXEC dodaj_zamowienie_szcz 1,6,1

--SELECT * FROM ZamowienieSzczegolowe
--SELECT * FROM Zamowienie
--EXEC dodaj_zamowienie_warsztatu 1,3,1,0
--EXEC dodaj_zamowienie_warsztatu 1,2,1,0
--EXEC dodaj_zamowienie_warsztatu 1,1,1,0
--SELECT * FROM  ZamowienieWarsztatu

--EXEC dodaj_uczestnika_konferencji 9, 9


--SELECT * FROM PrzychodyFirmy
--SELECT * FROM NieprawidlowaKwota
--SELECT * FROM NiepotwierdzoneDane
--SELECT * FROM NajpopularniejszeWarsztaty
--SELECT * FROM NajczestsiKlienci
--SELECT * FROM DostepneWarsztaty
--SELECT * FROM DostepneKonferencje

		 
