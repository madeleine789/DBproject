USE Konferencje
GO

--EXEC dodaj_temat_warsztatu "COBOL"
--EXEC dodaj_temat_konferencji "Abibliophobia"

--EXEC dodaj_konferencje 1, '05/05/2014', '05/05/2014', 150, 1
--EXEC dodaj_konferencje 1, '05/11/2014', '05/11/2014', 200, 1
--EXEC dodaj_konferencje 1, '06/01/2014', '06/02/2014', 300, 1
--EXEC dodaj_konferencje 1, '03/13/2014', '03/13/2014', 210, 1
--EXEC dodaj_konferencje 1, '09/09/2014', '09/09/2014', 210, 1

--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (1,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (1,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (1,3)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (2,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (2,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (2,3)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (3,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (3,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (3,3)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (4,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (4,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (4,3)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (5,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (5,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (5,3)

--SELECT * FROM Konferencja WHERE YEAR(DataRozpoczecia) LIKE '2014'

--EXEC dodaj_dzien_konferencji 1, '05/05/2014', 50
--EXEC dodaj_dzien_konferencji 2, '05/11/2014', 100
--EXEC dodaj_dzien_konferencji 3, '06/01/2014', 20
--EXEC dodaj_dzien_konferencji 3, '06/02/2014', 40
--EXEC dodaj_dzien_konferencji 4, '03/13/2014', 120
--EXEC dodaj_dzien_konferencji 5, '09/09/2014',1

----SELECT * FROM DzienKonferencji WHERE YEAR(DzienKonferencji) LIKE '2014'

--EXEC dodaj_warsztat 1, 6, 11, 2, '11:30:00', '14:30:00'
--EXEC dodaj_warsztat 1, 6, 40, 1, '12:00:00', '15:00:00'
--EXEC dodaj_warsztat 1, 6, 50, 1, '11:00:00', '12:00:00'
--EXEC dodaj_warsztat 1, 1, 20, 20, '14:30:00', '15:30:00'
--EXEC dodaj_warsztat 1, 2, 10, 20, '16:35:00', '19:35:00'
--EXEC dodaj_warsztat 1, 3, 100, 20, '12:35:00', '15:05:00'
--EXEC dodaj_warsztat 1, 4, 110, 20, '12:00:00', '15:00:00'

----SELECT * FROM Warsztat
----SELECT * FROM Osoba
----SELECT * FROM Klient

--EXEC dodaj_klienta_osoba "Julian", "Zak", NULL, "873938701", "jzak@jestemailem.pl", "Slupska 156", "Szczecin", "70-233", "Polska"
--EXEC dodaj_zamowienie 1, 5, "07/12/2012", 2, 1, 0, 0, "07/30/2012", 2
--EXEC dodaj_zamowienie_szcz 1,6,
--EXEC dodaj_zamowienie_warsztatu 1,3,1,0
--EXEC dodaj_zamowienie_warsztatu 1,2,1,0
--EXEC dodaj_zamowienie_warsztatu 1,1,1,0

--SELECT * FROM ZamowienieSzczegolowe
--SELECT * FROM Zamowienie WHERE YEAR(DataZlozeniaZamowienia) LIKE '2014'
--SELECT * FROM  ZamowienieWarsztatu

--DELETE FROM ZamowienieWarsztatu
--WHERE ID_ZamowieniaWarsztatu=1

--DELETE FROM ZamowienieSzczegolowe
--WHERE ID_ZamSzczegolowego=1

--EXEC dodaj_uczestnika_konferencji 1,1

--SELECT * FROM UczestnikKonferencji
--SELECT * FROM UczestnikWarsztatu

--EXEC dodaj_uczestnika_warsztatu 1,3
--EXEC dodaj_uczestnika_warsztatu 1,2
--EXEC dodaj_uczestnika_warsztatu 1,1




-------------------------------------------------------------------------------------------

--EXEC dodaj_konferencje 1, '05/05/2014', '05/05/2014', 150, 1
--EXEC dodaj_konferencje 22, '06/01/2014', '06/02/2014', 300, 1
--EXEC dodaj_konferencje 11, '03/09/2014', '03/10/2014', 110, 1
--EXEC dodaj_konferencje 32, '01/30/2014', '01/30/2014', 160, 1

--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (51,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (51,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (51,3)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (52,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (52,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (52,3)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (53,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (53,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (53,3)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (54,1)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (54,2)
--INSERT INTO ProgiCenowe (ID_Konferencji,ID_Progu) VALUES (54,3)

--EXEC dodaj_dzien_konferencji 51, '05/05/2014', 50
--EXEC dodaj_dzien_konferencji 52, '06/01/2014', 100
--EXEC dodaj_dzien_konferencji 52, '06/02/2014', 20
--EXEC dodaj_dzien_konferencji 53, '03/09/2014', 40
--EXEC dodaj_dzien_konferencji 53, '03/10/2014', 120
--EXEC dodaj_dzien_konferencji 54, '01/30/2014', 20

--EXEC dodaj_warsztat 1, 89, 11, 20, '11:30:00', '14:30:00'
--EXEC dodaj_warsztat 41, 90, 40, 30, '12:00:00', '15:00:00'
--EXEC dodaj_warsztat 32, 91, 50, 30, '11:00:00', '12:00:00'
--EXEC dodaj_warsztat 21, 91, 20, 40, '14:30:00', '15:30:00'
--EXEC dodaj_warsztat 20, 92, 10, 21, '16:35:00', '19:35:00'
--EXEC dodaj_warsztat 16, 93, 100, 50, '12:35:00', '15:05:00'
--EXEC dodaj_warsztat 12, 94, 110, 12, '12:00:00', '15:00:00'
--EXEC dodaj_warsztat 16, 91, 100, 50, '12:35:00', '15:05:00'
--EXEC dodaj_warsztat 12, 92, 110, 20, '12:00:00', '15:00:00'

--EXEC dodaj_zamowienie 170, 54, "01/10/2014", 1, 0, 0, 0, "01/24/2014", 2
--EXEC dodaj_zamowienie_szcz 3169,94,5

--EXEC dodaj_zamowienie 321, 54, "01/11/2014", 1, 0, 0, 0, "01/25/2014", 2
--EXEC dodaj_zamowienie_szcz 3170,94,7

--EXEC dodaj_zamowienie 162, 54, "01/10/2014", 1, 0, 0, 0, "01/24/2014", 2
--EXEC dodaj_zamowienie_szcz 3171,94,2

--EXEC dodaj_zamowienie 811, 54, "01/11/2014", 1, 1, 400, 0, "01/25/2014", 1
--EXEC dodaj_zamowienie_szcz 3172,94,7

--EXEC dodaj_zamowienie 200, 54, "01/10/2014", 1, 1, 500, 520, "01/24/2014", 1
--EXEC dodaj_zamowienie_szcz 3173,94,2




----SELECT * FROM Przychod
----SELECT * FROM NieprawidlowaKwota
----SELECT * FROM NiepotwierdzoneDaneee
----SELECT * FROM NajpopularniejszeWarsztaty
----SELECT * FROM NajczestsiKlienci
----SELECT * FROM KlienciNajwiekszaKwota
----SELECT * FROM DostepneWarsztaty
----SELECT * FROM DostepneKonferencje
----EXEC lista_osob_warsztat 1
----EXEC lista_osob_konferencja 2

		 
