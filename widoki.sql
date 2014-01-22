USE Konferencje
GO

------------  100 najczestszych klientow ----------
CREATE VIEW NajczestsiKlienci AS
SELECT TOP 100 Klient, Firma, Email, LiczbaZamowien
FROM
(
SELECT OS.Imie+' '+OS.Nazwisko Klient, 
       KLI.CzyFirma Firma, 
       OS.Email Email,
       COUNT(*) LiczbaZamowien
FROM Klient KLI
JOIN Zamowienie ZAM ON KLI.ID_Klienta = ZAM.ID_Klienta
JOIN Osoba OS ON OS.ID_Klienta = KLI.ID_Klienta
GROUP BY KLI.ID_Klienta, OS.Imie+' '+OS.Nazwisko, KLI.CzyFirma, OS.Email
UNION
SELECT FI.NazwaFirmy Klient,
       KLI.CzyFirma Firma, 
       FI.Email Email,
       COUNT(*) LiczbaZamowien
FROM Klient KLI
JOIN Zamowienie ZAM ON KLI.ID_Klienta = ZAM.ID_Klienta
JOIN Firma FI ON FI.ID_Klienta = KLI.ID_Klienta
GROUP BY KLI.ID_Klienta, FI.NazwaFirmy, KLI.CzyFirma, FI.Email
) UnionTable
GROUP BY Klient, Firma, Email, LiczbaZamowien
ORDER BY LiczbaZamowien DESC
GO

--------- 100 klientow ktorzy zlozyli zamowienia na najwieksza kwote ----
CREATE VIEW KlienciNajwiekszaKwota AS
SELECT TOP 100 ID, Klient, Firma, Email, KwotaZamowien
FROM
(
SELECT KLI.ID_Klienta ID,
	   OS.Imie+' '+OS.Nazwisko Klient, 
       KLI.CzyFirma Firma, 
       OS.Email Email,
       SUM(ZAM.Zaplacono) KwotaZamowien
FROM Klient KLI
JOIN Zamowienie ZAM ON KLI.ID_Klienta = ZAM.ID_Klienta
JOIN Osoba OS ON OS.ID_Klienta = KLI.ID_Klienta
GROUP BY KLI.ID_Klienta, OS.Imie+' '+OS.Nazwisko, KLI.CzyFirma, OS.Email
UNION
SELECT KLI.ID_Klienta ID,
	   FI.NazwaFirmy Klient,
       KLI.CzyFirma Firma, 
       FI.Email Email,
       SUM(ZAM.Zaplacono) KwotaZamowien
FROM Klient KLI
JOIN Zamowienie ZAM ON KLI.ID_Klienta = ZAM.ID_Klienta
JOIN Firma FI ON FI.ID_Klienta = KLI.ID_Klienta
GROUP BY KLI.ID_Klienta, FI.NazwaFirmy, KLI.CzyFirma, FI.Email
) UnionTable
GROUP BY ID, Klient, Firma, Email, KwotaZamowien
ORDER BY KwotaZamowien DESC
GO

----------- Dostepne konferencje dla klienta -------------
CREATE VIEW DostepneKonferencje AS
SELECT KON.Cena PodstawowaCenaZaOsobe, 
       (SELECT PR.ProcentCeny 
        FROM Prog PR
        WHERE 
        (DATEDIFF(MONTH,GETDATE(), KON.DataRozpoczecia) > PR.DolnyProgCzasowy AND 
        DATEDIFF(MONTH,GETDATE(), KON.DataRozpoczecia) <= PR.GornyProgCzasowy) OR 
        (PR.GornyProgCzasowy IS NULL AND 
        DATEDIFF(MONTH,GETDATE(), KON.DataRozpoczecia) > PR.DolnyProgCzasowy)) ObowiazujacyProgCenowy,
       KON.DataRozpoczecia DataRozpoczecia,
       KON.DataZakonczenia DataZakonczenia,
       TK.Opis OpisKonferencji
FROM Konferencja KON 
JOIN TematKonferencji TK ON TK.ID_TematuKonferencji=KON.ID_TematuKonferencji
JOIN StatusKonferencji SK ON SK.ID_StatusuKonferencji=KON.StatusKonferencji
WHERE SK.StatusKonferencji LIKE 'W trakcie'
GO

----------- Dostepne warsztaty dla klienta -------------
CREATE VIEW DostepneWarsztaty AS
SELECT WAR.Cena PodstawowaCenaZaOsobe,
	   TW.Opis TematWarsztatu,
	   TK.Opis ,
	   DK.DzienKonferencji DataWarsztatu,
	   WAR.LimitMiejscWarsztat - ISNULL(
		((SELECT SUM(ZW.LiczbaMiejsc)
		 FROM ZamowienieWarsztatu ZW
		 WHERE WAR.ID_Warsztatu=ZW.ID_Warsztatu
		 GROUP BY ZW.ID_Warsztatu)),0) LiczbaWolnychMiejsc
FROM Warsztat WAR
JOIN DzienKonferencji DK ON WAR.ID_DniaKonferencji=DK.ID_DniaKonferencji
JOIN Konferencja KON ON KON.ID_Konferencji=DK.ID_Konferencji
JOIN TematWarsztatu TW ON TW.ID_TematuWarsztatu=WAR.ID_TematuWarsztatu
JOIN TematKonferencji TK ON TK.ID_TematuKonferencji=KON.ID_TematuKonferencji
WHERE GETDATE() < DK.DzienKonferencji
AND  WAR.LimitMiejscWarsztat - ISNULL(
		((SELECT SUM(ZW.LiczbaMiejsc)
		 FROM ZamowienieWarsztatu ZW
		 WHERE WAR.ID_Warsztatu=ZW.ID_Warsztatu
		 GROUP BY ZW.ID_Warsztatu)),0) > 0
GO							 
GO							 

------------ Firmy ktore nie maja potwierdzonych danych uczestnikow dla zamowien przy uplywajacym czasie ----
CREATE VIEW NiepotwierdzoneDane AS
SELECT FI.NazwaFirmy,
       FI.Telefon,
       FI.Email
FROM Zamowienie ZAM
JOIN Klient KLI ON KLI.ID_Klienta=ZAM.ID_Klienta
JOIN ZamowienieSzczegolowe ZS ON ZS.ID_Zamowienia=ZAM.ID_Zamowienia
JOIN ZamowienieWarsztatu ZW ON ZW.ID_ZamSzczegolowego=ZS.ID_ZamSzczegolowego
JOIN Firma FI ON FI.ID_Klienta=KLI.ID_Klienta AND KLI.CzyFirma = 1
WHERE (ZAM.StatusRezerwacji = 1 OR ZW.StatusRezerwacji = 1) AND 
      (DATEDIFF(DAY,ZAM.DataZlozeniaZamowienia,GETDATE()) >= 7 AND 
       DATEDIFF(DAY,ZAM.DataZlozeniaZamowienia,GETDATE()) <= 14)
GO

---------- Klienci ktorzy wplacili nieprawidlowa kwote -------
CREATE VIEW NieprawidlowaKwota AS
SELECT ID, 
       Klient, 
       Firma, 
       Email, 
       Zaplacono, 
       DoZaplaty
FROM
(
SELECT KLI.ID_Klienta ID, 
       OS.Imie+' '+OS.Nazwisko Klient, 
       KLI.CzyFirma Firma, OS.Email Email, 
       ZAM.Zaplacono Zaplacono, 
       ZAM.DoZapltay DoZaplaty, 
       ZAM.TerminPlatnosci TerminPlatnosci
FROM Klient KLI
JOIN Zamowienie ZAM ON	 KLI.ID_Klienta = ZAM.ID_Klienta
JOIN Osoba OS ON OS.ID_Klienta = KLI.ID_Klienta
UNION
SELECT KLI.ID_Klienta ID, 
       FI.NazwaFirmy Klient, 
       KLI.CzyFirma Firma, 
       FI.Email Email, 
       ZAM.Zaplacono Zaplacono, 
       ZAM.DoZapltay DoZapltay, 
       ZAM.TerminPlatnosci TerminPlatnosci
FROM Klient KLI
JOIN Zamowienie ZAM ON KLI.ID_Klienta = ZAM.ID_Klienta
JOIN Firma FI ON FI.ID_Klienta = KLI.ID_Klienta
) UnionTable
WHERE DoZaplaty != Zaplacono AND DATEDIFF(DAY, TerminPlatnosci,GETDATE()) >= 7
GO

-------- Przychody firmy podzielone na lata i miesiace ------
CREATE VIEW Przychod AS 
SELECT YEAR(ZAM.DataZlozeniaZamowienia) Rok,
	   (CASE 
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=1 THEN 'Styczen'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=2 THEN 'Luty'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=3 THEN 'Marzec'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=4 THEN 'Kwiecien'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=5 THEN 'Maj'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=6 THEN 'Czerwiec'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=7 THEN 'Lipiec'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=8 THEN 'Sierpien'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=9 THEN 'Wrzesien'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=10 THEN 'Pazdziernik'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=11 THEN 'Listopad'
		WHEN MONTH(ZAM.DataZlozeniaZamowienia)=12 THEN 'Grudzien'
	   END) Miesiac,
	   SUM(ZAM.DoZapltay) Przychod
FROM Zamowienie ZAM 
GROUP BY YEAR(ZAM.DataZlozeniaZamowienia), MONTH(ZAM.DataZlozeniaZamowienia) 
WITH ROLLUP
GO

--------- Najpopularniejsze tematy warsztatow ----------
CREATE VIEW NajpopularniejszeWarsztaty AS
SELECT TOP 10 
       WAR.ID_Warsztatu ID, 
       CAST(TW.Opis AS VARCHAR(200)) TematWarsztatu, 
       SUM(ZW.LiczbaMiejsc) SumaZarezerwowanychMiejsc
FROM Warsztat WAR
JOIN TematWarsztatu TW ON WAR.ID_TematuWarsztatu=TW.ID_TematuWarsztatu
JOIN ZamowienieWarsztatu ZW ON ZW.ID_Warsztatu=WAR.ID_Warsztatu
GROUP BY WAR.ID_Warsztatu, CAST(TW.Opis AS VARCHAR(200))
ORDER BY SUM(ZW.LiczbaMiejsc) DESC
GO

--------- Aktualne zamowienia ---------
CREATE VIEW AktualneZamowienia AS
SELECT OS.Imie+' '+OS.Nazwisko Klient, 
	   ZAM.DoZapltay, ZAM.Zaplacono,
	   ZAM.StatusPlatnosci, 
	   ZAM.TerminPlatnosci, 
	   ZAM.StatusRezerwacji, 
	   KON.DataRozpoczecia DataRozpoczeciaKonferencji
FROM Zamowienie ZAM
JOIN Klient KLI ON KLI.ID_Klienta=ZAM.ID_Klienta
JOIN Osoba OS ON OS.ID_Klienta=KLI.ID_Klienta
JOIN Konferencja KON ON KON.ID_Konferencji=ZAM.ID_Konferencji
WHERE ZAM.StatusRejestracji = 1 
UNION
SELECT FI.NazwaFirmy Klient, 
	   ZAM.DoZapltay, 
	   ZAM.Zaplacono,
	   ZAM.StatusPlatnosci, 
	   ZAM.TerminPlatnosci, 
	   ZAM.StatusRezerwacji,
	   KON.DataRozpoczecia DataRozpoczeciaKonferencji
FROM Zamowienie ZAM
JOIN Klient KLI ON KLI.ID_Klienta=ZAM.ID_Klienta
JOIN Firma FI ON FI.ID_Klienta=KLI.ID_Klienta
JOIN Konferencja KON ON KON.ID_Konferencji=ZAM.ID_Konferencji
WHERE ZAM.StatusRejestracji = 1 
GO

---------- Lista osobowa dla danej konferencji ---------
CREATE PROCEDURE lista_osob_konferencja 
		@id_dnia INT
AS
BEGIN
	SET NOCOUNT ON
	SELECT OS.Imie,OS.Nazwisko,OS.NrAlbumu, ISNULL(FI.NazwaFirmy,'Osoba prywatna') Klient
	FROM UczestnikKonferencji UK
	JOIN Osoba OS ON OS.ID_Osoby=UK.ID_Osoby
	JOIN ZamowienieSzczegolowe ZS ON ZS.ID_ZamSzczegolowego=UK.ID_ZamSzczegolowego
	LEFT OUTER JOIN Pracownik PR ON PR.ID_Osoby=OS.ID_Osoby
	LEFT OUTER JOIN Firma FI ON FI.NIP=PR.NIP
	WHERE ZS.ID_DniaKonferencji=@id_dnia
END
GO

------------ Lista osobowa dla danego warsztatu --------
CREATE PROCEDURE lista_osob_warsztat 
		@id_warsztatu INT
AS
BEGIN
	SET NOCOUNT ON
	SELECT OS.Imie,OS.Nazwisko,OS.NrAlbumu, ISNULL(FI.NazwaFirmy,'Osoba prywatna') Klient
	FROM UczestnikWarsztatu UW
	JOIN UczestnikKonferencji UK ON UW.ID_UczestnikaKonferencji=UK.ID_UczestnikaKonferencji
	JOIN Osoba OS ON OS.ID_Osoby=UK.ID_Osoby
	JOIN ZamowienieWarsztatu ZW ON ZW.ID_ZamowieniaWarsztatu=UW.ID_ZamowieniaWarsztatu
	JOIN Warsztat WAR ON WAR.ID_Warsztatu=ZW.ID_Warsztatu
	LEFT OUTER JOIN Pracownik PR ON PR.ID_Osoby=OS.ID_Osoby
	LEFT OUTER JOIN Firma FI ON FI.NIP=PR.NIP
	WHERE WAR.ID_Warsztatu = @id_warsztatu
END
GO