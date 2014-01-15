USE Konferencje
GO

--EXEC dodaj_konferencje 50, "05/05/2014", "05/05/2014", 150, 1
--EXEC dodaj_konferencje 10, "05/11/2014", "05/11/2014", 200, 1
--EXEC dodaj_konferencje 2, "06/01/2014", "06/02/2014", 300, 1
--EXEC dodaj_konferencje 5, "03/13/2014", "03/13/2014", 210, 1

--SELECT * FROM Konferencja WHERE YEAR(DataRozpoczecia) LIKE '2014'

--EXEC dodaj_dzien_konferencji 51, "05/05/2014", 50
--EXEC dodaj_dzien_konferencji 52, "05/11/2014", 100
--EXEC dodaj_dzien_konferencji 53, "06/01/2014", 20
--EXEC dodaj_dzien_konferencji 53, "06/02/2014", 40
--EXEC dodaj_dzien_konferencji 54, "03/13/2014", 120

--SELECT * FROM DzienKonferencji WHERE YEAR(DzienKonferencji) LIKE '2014'

--EXEC dodaj_warsztat 3, 105, 50, 20, "12:40:00", "15:40:00"
--EXEC dodaj_warsztat 12, 106, 40, 20, "12:00:00", "15:00:00"
--EXEC dodaj_warsztat 32, 107, 20, 20, "14:30:00", "15:30:00"
--EXEC dodaj_warsztat 45, 108, 10, 20, "16:35:00", "19:35:00"
--EXEC dodaj_warsztat 46, 109, 100, 20, "12:35:00", "15:05:00"
--EXEC dodaj_warsztat 3, 105, 110, 20, "12:00:00", "15:00:00"

--SELECT * FROM PrzychodyFirmy
--SELECT * FROM NieprawidlowaKwota
--SELECT * FROM NiepotwierdzoneDane
--SELECT * FROM NajpopularniejszeWarsztaty
--SELECT * FROM NajczestsiKlienci
--SELECT * FROM DostepneWarsztaty
--SELECT * FROM DostepneKonferencje

		 
