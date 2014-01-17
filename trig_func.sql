USE Konferencje
GO

--
CREATE FUNCTION jaki_prog (@id_zamowienia INT)
RETURNS SMALLINT AS
BEGIN
	DECLARE @data_zamowienia AS DATE
	DECLARE @obowiazujacy_prog AS SMALLINT
	
	SET @data_zamowienia = (SELECT ZAM.DataZlozeniaZamowienia FROM Zamowienie ZAM WHERE ZAM.ID_Zamowienia=@id_zamowienia)
	SET @obowiazujacy_prog = (
		SELECT PR.ProcentCeny
		FROM Zamowienie ZAM
		JOIN Konferencja KON ON KON.ID_Konferencji=ZAM.ID_Konferencji
		JOIN ProgiCenowe PC ON KON.ID_Konferencji=PC.ID_Konferencji
		JOIN Prog PR ON PR.ID_Progu=PC.ID_Progu
		WHERE ZAM.ID_Zamowienia=@id_zamowienia AND
		((DATEDIFF(MONTH,@data_zamowienia, KON.DataRozpoczecia) > PR.DolnyProgCzASowy AND 
		DATEDIFF(MONTH,@data_zamowienia, KON.DataRozpoczecia) <= PR.GornyProgCzASowy) OR 
		(PR.GornyProgCzASowy IS NULL AND 
		DATEDIFF(MONTH,@data_zamowienia, KON.DataRozpoczecia) > PR.DolnyProgCzASowy))
	)
	RETURN @obowiazujacy_prog
END
GO

--
CREATE FUNCTION czy_student(@id_zamowienia INT)
RETURNS BIT AS
BEGIN

	DECLARE @student AS BIT
	IF((SELECT KLI.CzyFirma
		FROM Klient KLI
	    JOIN Zamowienie ZAM ON KLI.ID_Klienta=ZAM.ID_Klienta 
	    WHERE ZAM.ID_Zamowienia=@id_zamowienia)=1)
	SET @student = 0
	ELSE IF((SELECT OS.NrAlbumu
		    FROM Klient KLI
	        JOIN Zamowienie ZAM ON (KLI.ID_Klienta=ZAM.ID_Klienta AND KLI.CzyFirma=0)
			JOIN Osoba OS ON OS.ID_Klienta=KLI.ID_Klienta
			WHERE ZAM.ID_Zamowienia=@id_zamowienia) IS NULL)
		 SET @student = 0
	     ELSE SET @student = 1	
	     
	RETURN @student

END
GO

--
CREATE TRIGGER Trigger_dodaj_dzien
ON DzienKonferencji
INSTEAD OF INSERT
AS
BEGIN
DECLARE @Idkonferencji INT
DECLARE @data DATE

SET @idkonferencji = (SELECT ID_Konferencji FROM inserted)
SET @data = (SELECT DzienKonferencji FROM inserted)

IF EXISTS (SELECT *
		   FROM DzienKonferencji DK 
		   JOIN Konferencja KON ON KON.ID_Konferencji=DK.ID_Konferencji
		   WHERE KON.ID_Konferencji=@Idkonferencji AND DK.DzienKonferencji=@data)
BEGIN
  	RAISERROR('Ustalono juz konferencje w tym dniu.',16,1)
  	ROLLBACK TRANSACTION
END
ELSE BEGIN
	INSERT INTO DzienKonferencji
	SELECT INS.ID_Konferencji,INS.DzienKonferencji,INS.LimitMiejscKonferencja  FROM inserted INS
END

END
GO

--
CREATE TRIGGER Trigger_dodaj_konferencje
   ON  Konferencja
   FOR INSERT
AS
BEGIN
  	DECLARE @poczatek DATE
  	DECLARE @koniec DATE
  	SET @poczatek = (SELECT DataRozpoczecia FROM inserted)
  	SET @koniec = (SELECT DataZakonczenia FROM inserted)
  	IF (@koniec < @poczatek)
  	BEGIN
        	RAISERROR('Konferencja nie moze sie zaczynac pozniej niz konczy',16,1)
        	ROLLBACK TRANSACTION
  	END
END
GO

--
CREATE TRIGGER Trigger_limit_miejsc_konferencja
   ON  ZamowienieSzczegolowe
   INSTEAD OF INSERT
AS
BEGIN
  	SET NOCOUNT ON;
  	DECLARE @potrzebne_miejsca INT
  	DECLARE @wolne_miejsca INT
  	DECLARE @limit_miejsc INT
  	DECLARE @idkonferencji INT
  	DECLARE @wykorzystane_miejsca INT
  	DECLARE @id_zam_szczeg INT
  	
  	SET @id_zam_szczeg = (SELECT ID_ZamSzczegolowego FROM inserted)
  	SET @idkonferencji = (SELECT ID_DniaKonferencji FROM inserted)
  	SET @potrzebne_miejsca = (SELECT LiczbaMiejsc FROM inserted)
  	SET @limit_miejsc = (SELECT DK.LimitMiejscKonferencja
  						  FROM ZamowienieSzczegolowe ZS
  						  JOIN DzienKonferencji DK ON ZS.ID_DniaKonferencji=DK.ID_DniaKonferencji
  						  WHERE ZS.ID_ZamSzczegolowego = @id_zam_szczeg)
	SET @wykorzystane_miejsca = (SELECT SUM(ZS.LiczbaMiejsc)
  								 FROM ZamowienieSzczegolowe ZS
  								 JOIN DzienKonferencji DK ON ZS.ID_DniaKonferencji=DK.ID_DniaKonferencji
  								 GROUP BY DK.ID_DniaKonferencji
  								 HAVING DK.ID_DniaKonferencji = @idkonferencji)
  	SET @wolne_miejsca = @limit_miejsc - @wykorzystane_miejsca
  	
  	IF @potrzebne_miejsca > @wolne_miejsca 
  	BEGIN
        RAISERROR('Nie ma odpowiedniej ilosci wolnych miejsc.',16,1)
        ROLLBACK TRANSACTION
    END
		ELSE 
		BEGIN
			INSERT INTO ZamowienieSzczegolowe
			SELECT INS.ID_DniaKonferencji,INS.ID_Zamowienia,INS.LiczbaMiejsc FROM inserted INS
		END
        	
END
GO

--
CREATE TRIGGER Trigger_limit_miejsc_warsztat
   ON  ZamowienieWarsztatu
   INSTEAD OF INSERT
AS
BEGIN
  	SET NOCOUNT ON;
  	DECLARE @potrzebne_miejsca INT
  	DECLARE @wolne_miejsca INT
  	DECLARE @limit_miejsc INT
  	DECLARE @id_warsztatu INT
  	DECLARE @wykorzystane_miejsca INT
  	
  	SET @id_warsztatu= (SELECT ID_Warsztatu FROM inserted)
  	SET @potrzebne_miejsca = (SELECT LiczbaMiejsc FROM inserted)
  	SET @limit_miejsc = (SELECT LimitMiejscWarsztat
  						 FROM Warsztat WAR
  						 JOIN ZamowienieWarsztatu ZW ON ZW.ID_Warsztatu=WAR.ID_Warsztatu
  						 WHERE WAR.ID_Warsztatu=@id_warsztatu)
	SET @wykorzystane_miejsca = (SELECT SUM(ZW.LiczbaMiejsc)
  								 FROM ZamowienieWarsztatu ZW
  								 JOIN Warsztat WAR ON WAR.ID_Warsztatu=ZW.ID_ZamowieniaWarsztatu
  								 GROUP BY WAR.ID_Warsztatu
  								 HAVING WAR.ID_Warsztatu = @id_warsztatu)
  	SET @wolne_miejsca = @limit_miejsc - @wykorzystane_miejsca
  	
  	IF @potrzebne_miejsca > @wolne_miejsca
	BEGIN
      	RAISERROR('Nie ma odpowiedniej ilosci wolnych miejsc.',16,1)
      	ROLLBACK TRANSACTION
	END
		ELSE
		BEGIN
			INSERT INTO ZamowienieWarsztatu
			SELECT INS.ID_Warsztatu,INS.ID_ZamSzczegolowego,INS.LiczbaMiejsc,INS.StatusRezerwacji FROM inserted INS
		END
END
GO

--
CREATE TRIGGER Trigger_dodaj_warsztat
ON  Warsztat
FOR INSERT
AS
BEGIN
  	SET NOCOUNT ON;
  	DECLARE @poczatek TIME
  	DECLARE @koniec TIME
  	SET @poczatek = (SELECT GodzinaRozpoczecia FROM inserted)
  	SET @koniec = (SELECT GodzinaZakonczenia FROM inserted)
  	
  	IF (@koniec <= @poczatek)
  	BEGIN
        	RAISERROR('Warsztat nie moze konczyc sie wczesniej niz sie zaczyna.',16,1)
        	ROLLBACK TRANSACTION
  	END
END
GO

--
CREATE TRIGGER Trigger_dodaj_uczestnika_warsztatu
ON UczestnikWarsztatu
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @poczatek_warsztatu TIME	
	DECLARE @koniec_warsztatu TIME
	DECLARE @id_zamowienia_szczeg INT
	DECLARE @id_osoby INT
	DECLARE @liczba_warsztatow SMALLINT
	
	SET @id_osoby = (SELECT UK.ID_Osoby
					 FROM inserted INS
					 JOIN UczestnikKonferencji UK ON INS.ID_UczestnikaKonferencji=UK.ID_UczestnikaKonferencji)
	
	SET @id_zamowienia_szczeg = (SELECT ZS.ID_ZamSzczegolowego
								 FROM inserted INS
								 JOIN ZamowienieWarsztatu ZW ON ZW.ID_ZamowieniaWarsztatu=INS.ID_ZamowieniaWarsztatu
								 JOIN ZamowienieSzczegolowe ZS ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego)
	SET @poczatek_warsztatu = (SELECT WAR.GodzinaRozpoczecia
							   FROM inserted INS 
							   JOIN ZamowienieWarsztatu ZW ON ZW.ID_ZamowieniaWarsztatu=INS.ID_ZamowieniaWarsztatu
							   JOIN Warsztat WAR ON WAR.ID_Warsztatu=ZW.ID_Warsztatu)
	SET @koniec_warsztatu = (SELECT WAR.GodzinaZakonczenia
							 FROM inserted INS 
							 JOIN ZamowienieWarsztatu ZW ON ZW.ID_ZamowieniaWarsztatu=INS.ID_ZamowieniaWarsztatu
							 JOIN Warsztat WAR ON WAR.ID_Warsztatu=ZW.ID_Warsztatu)
	SET @liczba_warsztatow = (SELECT COUNT(*)
							  FROM ZamowienieWarsztatu ZW
							  JOIN Warsztat WAR ON ZW.ID_Warsztatu=WAR.ID_Warsztatu
							  JOIN UczestnikWarsztatu UW ON UW.ID_ZamowieniaWarsztatu=ZW.ID_ZamowieniaWarsztatu
							  JOIN ZamowienieSzczegolowe ZS ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
							  JOIN UczestnikKonferencji UK ON UK.ID_UczestnikaKonferencji=UW.ID_UczestnikaKonferencji
							  WHERE (ZS.ID_ZamSzczegolowego=@id_zamowienia_szczeg AND UK.ID_Osoby=@id_osoby) AND
								    (WAR.GodzinaRozpoczecia>@poczatek_warsztatu AND WAR.GodzinaRozpoczecia<@koniec_warsztatu)OR
								    (WAR.GodzinaZakonczenia>@poczatek_warsztatu AND WAR.GodzinaZakonczenia<@koniec_warsztatu)) 
	IF(@liczba_warsztatow>0)
	BEGIN
        	RAISERROR('Osoba nie moze isc na dwa warsztaty jednoczesnie.',16,1)
        	ROLLBACK TRANSACTION		
	END	
	ELSE
	BEGIN
		INSERT INTO UczestnikWarsztatu
		SELECT INS.ID_UczestnikaKonferencji, INS.ID_ZamowieniaWarsztatu FROM inserted INS
	END						 
	
END
GO

--
CREATE TRIGGER Trigger_czymozna_usunac_zamszczeg
ON ZamowienieSzczegolowe
INSTEAD OF DELETE
AS
BEGIN 
	DECLARE @id_zamowienia INT
	DECLARE @dzisiejsza_data DATE
	DECLARE @data_konferencji DATE
	DECLARE @id_zam_szczegolowego INT
	
	SET @id_zam_szczegolowego = (SELECT ID_ZamSzczegolowego FROM deleted)
	SET @dzisiejsza_data = GETDATE()
	SET @data_konferencji = (SELECT DK.DzienKonferencji
							 FROM ZamowienieSzczegolowe ZS
							 JOIN DzienKonferencji DK ON ZS.ID_DniaKonferencji=DK.ID_DniaKonferencji
							 WHERE ZS.ID_ZamSzczegolowego = @id_zam_szczegolowego)
	IF(DATEDIFF(DAY,@dzisiejsza_data,@data_konferencji)<14)
	BEGIN
		RAISERROR('Nie mozna juz usunac zamowienia.',16,1)
        ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		DELETE FROM UczestnikWarsztatu 
			WHERE ID_ZamowieniaWarsztatu = (SELECT ZW.ID_ZamowieniaWarsztatu
											FROM ZamowienieWarsztatu ZW
											JOIN ZamowienieSzczegolowe ZS ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
											WHERE ZS.ID_ZamSzczegolowego = @id_zam_szczegolowego)
		DELETE FROM ZamowienieWarsztatu WHERE ID_ZamSzczegolowego = @id_zam_szczegolowego
		DELETE FROM ZamowienieSzczegolowe WHERE ID_ZamSzczegolowego = @id_zam_szczegolowego
		COMMIT
	END
END
GO

--
CREATE TRIGGER Trigger_czymozna_usunac_warsztat
ON ZamowienieWarsztatu
INSTEAD OF DELETE
AS
BEGIN 
	DECLARE @id_zamowienia INT
	DECLARE @dzisiejsza_data DATE
	DECLARE @data_konferencji DATE
	DECLARE @id_zam_szczegolowego INT
	
	SET @id_zam_szczegolowego = (SELECT ID_ZamSzczegolowego FROM deleted)
	SET @dzisiejsza_data = GETDATE()
	SET @data_konferencji = (SELECT DK.DzienKonferencji
							 FROM ZamowienieSzczegolowe ZS
							 JOIN DzienKonferencji DK ON ZS.ID_DniaKonferencji=DK.ID_DniaKonferencji
							 WHERE ZS.ID_ZamSzczegolowego = @id_zam_szczegolowego)
	IF(DATEDIFF(DAY,@dzisiejsza_data,@data_konferencji)<14)
	BEGIN
		RAISERROR('Nie mozna juz usunac zamowienia.',16,1)
        ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		DELETE FROM UczestnikWarsztatu 
			WHERE ID_ZamowieniaWarsztatu = (SELECT ZW.ID_ZamowieniaWarsztatu
											FROM ZamowienieWarsztatu ZW
											JOIN ZamowienieSzczegolowe ZS ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
											WHERE ZS.ID_ZamSzczegolowego = @id_zam_szczegolowego)
		DELETE FROM ZamowienieWarsztatu WHERE ID_ZamSzczegolowego = @id_zam_szczegolowego
		COMMIT
	END
END
GO

--
CREATE TRIGGER Trigger_akt_dozaplaty_zamszczeg
ON ZamowienieSzczegolowe
AFTER INSERT
AS BEGIN
	DECLARE @id_zamowienia AS INT
	DECLARE @cena_za_osobe AS MONEY
	DECLARE @prog AS SMALLINT
	DECLARE @znizka AS SMALLINT
	DECLARE @ilosc_osob AS INT
	DECLARE @dotychczasowa_oplata AS MONEY
	
	SET @id_zamowienia = (SELECT ID_Zamowienia FROM inserted)
	
	SET @cena_za_osobe = (SELECT KON.Cena
						  FROM ZamowienieSzczegolowe ZS
						  JOIN DzienKonferencji DK ON DK.DzienKonferencji=ZS.ID_DniaKonferencji
						  JOIN Konferencja KON ON KON.ID_Konferencji=DK.ID_Konferencji
						  WHERE ZS.ID_Zamowienia=@id_zamowienia
						  )
						  
	SET @prog = jaki_prog(@id_zamowienia)	
	IF(czy_student(@id_zamowienia)) SET @znizka = (SELECT ZS.ProcentZnizki FROM ZnizkaStudencka ZS)
	ELSE SET @znizka = 100
	
	SET @ilosc_osob = (SELECT LiczbaMiejsc FROM inserted)
	
	SET @dotychczasowa_oplata = (SELECT DoZapltay FROM Zamowienie ZAM WHERE ZAM.ID_Zamowienia=@id_zamowienia)
	
	UPDATE Zamowienie
	SET DoZapltay = @dotychczasowa_oplata + (@znizka/100)*(@prog/100)*(@ilosc_osob*@cena_za_osobe)
	WHERE ID_Zamowienia=@id_zamowienia
				
END
GO

--
CREATE TRIGGER Trigger_akt_dozaplaty_warsztat
ON ZamowienieWarsztatu
AFTER INSERT
AS BEGIN
	DECLARE @id_zamowienia AS INT
	DECLARE @cena_za_osobe AS MONEY
	DECLARE @znizka AS SMALLINT
	DECLARE @ilosc_osob AS INT
	DECLARE @dotychczasowa_oplata AS MONEY
	
	SET @id_zamowienia = (SELECT ZS.ID_Zamowienia
						  FROM ZamowienieSzczegolowe ZS
						  JOIN ZamowienieWarsztatu ZW ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
						  WHERE ZW.ID_ZamowieniaWarsztatu = (SELECT ID_ZamowieniaWarsztatu FROM inserted))
	
	SET @cena_za_osobe = (SELECT WAR.Cena
						  FROM Warsztat WAR
						  JOIN ZamowienieWarsztatu ZW ON ZW.ID_Warsztatu=WAR.ID_Warsztatu
						  WHERE ZW.ID_ZamowieniaWarsztatu = (SELECT ID_ZamowieniaWarsztatu FROM inserted)
						  )
						  
	IF(czy_student(@id_zamowienia)) SET @znizka = (SELECT ZS.ProcentZnizki FROM ZnizkaStudencka ZS)
	ELSE SET @znizka = 100
	
	SET @ilosc_osob = (SELECT LiczbaMiejsc FROM inserted)
	
	SET @dotychczasowa_oplata = (SELECT DoZapltay FROM Zamowienie ZAM WHERE ZAM.ID_Zamowienia=@id_zamowienia)
	
	UPDATE Zamowienie
	SET DoZapltay = @dotychczasowa_oplata + (@znizka/100)*(@ilosc_osob*@cena_za_osobe)
	WHERE ID_Zamowienia=@id_zamowienia
				
END
GO

