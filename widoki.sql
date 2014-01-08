USE Konferencje
GO

------------  100 najczestszych klientow ----------
CREATE VIEW NajczestsiKlienci AS
SELECT TOP 100 ID, Klient, Firma, Email
FROM
(
SELECT KLI.ID_Klienta ID, 
       OS.Imie+' '+OS.Nazwisko Klient, 
       KLI.CzyFirma Firma, 
       OS.Email Email
FROM Klient KLI
JOIN Zamowienie ZAM ON KLI.ID_Klienta = ZAM.ID_Klienta
JOIN Osoba OS ON OS.ID_Klienta = KLI.ID_Klienta
GROUP BY KLI.ID_Klienta, OS.Imie+' '+OS.Nazwisko, KLI.CzyFirma, OS.Email
UNION
SELECT KLI.ID_Klienta ID, 
       FI.NazwaFirmy Klient,
       KLI.CzyFirma Firma, 
       FI.Email Email
FROM Klient KLI
JOIN Zamowienie ZAM ON KLI.ID_Klienta = ZAM.ID_Klienta
JOIN Firma FI ON FI.ID_Klienta = KLI.ID_Klienta
GROUP BY KLI.ID_Klienta, FI.NazwaFirmy, KLI.CzyFirma, FI.Email
) UnionTable
GROUP BY ID, Klient, Firma, Email
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
WHERE KON.StatusKonferencji LIKE 'W trakcie'
GO

----------- Dostepne warsztaty dla klienta -------------
CREATE VIEW DostepneWarsztaty AS
SELECT WAR.Cena PodstawowaCenaZaOsobe,
	   TW.Opis TematWarsztatu,
	   TK.Opis ,
	   DK.DzienKonferencji DataWarsztatu,
	   WAR.LimitMiejscWarsztat - 
		(SELECT SUM(ZW.LiczbaMiejsc)
		FROM ZamowienieWarsztatu ZW
		WHERE WAR.ID_Warsztatu=ZW.ID_Warsztatu
		GROUP BY ZW.ID_Warsztatu) LiczbaWolnychMiejsc
FROM Warsztat WAR
JOIN DzienKonferencji DK ON WAR.ID_DniaKonferencji=DK.ID_DniaKonferencji
JOIN Konferencja KON ON KON.ID_Konferencji=DK.ID_Konferencji
JOIN TematWarsztatu TW ON TW.ID_TematuWarsztatu=WAR.ID_TematuWarsztatu
JOIN TematKonferencji TK ON TK.ID_TematuKonferencji=KON.ID_TematuKonferencji
WHERE WAR.LimitMiejscWarsztat > (SELECT SUM(ZW.LiczbaMiejsc)
				 FROM ZamowienieWarsztatu ZW
				 WHERE WAR.ID_Warsztatu=ZW.ID_Warsztatu
				 GROUP BY ZW.ID_Warsztatu)
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
WHERE (ZAM.StatusRezerwacji = 0 OR ZW.StatusRezerwacji = 0) AND 
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
	   DoZapltay
FROM
(
SELECT KLI.ID_Klienta ID, 
       OS.Imie+' '+OS.Nazwisko Klient, 
       KLI.CzyFirma Firma, OS.Email Email, 
       ZAM.Zaplacono Zaplacono, 
       ZAM.DoZapltay DoZapltay, 
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
WHERE DoZapltay != Zaplacono AND DATEDIFF(DAY, TerminPlatnosci,GETDATE()) >= 7
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
WHERE ZAM.StatusPlatnosci LIKE 'Zaplacone'
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
