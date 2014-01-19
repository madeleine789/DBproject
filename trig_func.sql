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
CREATE FUNCTION kwota_za_zam_warsztatu (@id_zam_warsztatu INT)
RETURNS MONEY
AS BEGIN
	DECLARE @id_zamowienia AS INT
	DECLARE @cena_za_osobe AS MONEY
	DECLARE @znizka AS SMALLINT
	DECLARE @ilosc_osob AS INT
	DECLARE @kwota MONEY
	
	SET @id_zamowienia = (SELECT ZS.ID_Zamowienia
						  FROM ZamowienieSzczegolowe ZS
						  JOIN ZamowienieWarsztatu ZW ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
						  WHERE ZW.ID_ZamowieniaWarsztatu = @id_zam_warsztatu)
	
	SET @cena_za_osobe = (SELECT WAR.Cena
						  FROM Warsztat WAR
						  JOIN ZamowienieWarsztatu ZW ON ZW.ID_Warsztatu=WAR.ID_Warsztatu
						  WHERE ZW.ID_ZamowieniaWarsztatu = @id_zam_warsztatu
						  )
						  
	IF(dbo.czy_student(@id_zamowienia)=1) SET @znizka = (SELECT ZS.ProcentZnizki FROM ZnizkaStudencka ZS)
	ELSE SET @znizka = 100
	
	SET @ilosc_osob = (SELECT ZW.LiczbaMiejsc
					   FROM ZamowienieWarsztatu ZW
					   WHERE ZW.ID_ZamowieniaWarsztatu=@id_zam_warsztatu)
	
	SET @kwota = (@znizka/100.0)*(@ilosc_osob*@cena_za_osobe)
	RETURN @kwota
				
END
GO

--
CREATE FUNCTION kwota_za_zam_szczeg (@id_zam_szczeg INT)
RETURNS MONEY
AS
BEGIN
	DECLARE @kwota MONEY
	DECLARE @cena_za_osobe AS MONEY
	DECLARE @prog AS SMALLINT
	DECLARE @znizka AS SMALLINT
	DECLARE @ilosc_osob AS INT
	DECLARE @id_zamowienia AS INT
	
	SET @id_zamowienia = (SELECT ZS.ID_Zamowienia
						  FROM ZamowienieSzczegolowe ZS
						  WHERE ZS.ID_ZamSzczegolowego=@id_zam_szczeg)
	
	SET @cena_za_osobe = (SELECT KON.Cena
						  FROM ZamowienieSzczegolowe ZS
						  JOIN DzienKonferencji DK ON DK.ID_DniaKonferencji=ZS.ID_DniaKonferencji
						  JOIN Konferencja KON ON KON.ID_Konferencji=DK.ID_Konferencji
						  WHERE ZS.ID_Zamowienia=@id_zamowienia
						  )
						  
	SET @prog = dbo.jaki_prog(@id_zamowienia)	
	IF(dbo.czy_student(@id_zamowienia)=1) SET @znizka = (SELECT ZS.ProcentZnizki FROM ZnizkaStudencka ZS)
	ELSE SET @znizka = 100
	
	SET @ilosc_osob = (SELECT ZS.LiczbaMiejsc
					   FROM ZamowienieSzczegolowe ZS
					   WHERE ZS.ID_ZamSzczegolowego=@id_zam_szczeg)
					   
	SET @kwota = (@znizka/100.0)*(@prog/100.0)*(@ilosc_osob*@cena_za_osobe)
				
	RETURN @kwota
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
 
  	SET @idkonferencji = (SELECT ID_DniaKonferencji FROM inserted)
  	SET @potrzebne_miejsca = (SELECT LiczbaMiejsc FROM inserted)
  	SET @limit_miejsc = (SELECT DK.LimitMiejscKonferencja
  						 FROM DzienKonferencji DK
  						 WHERE DK.ID_DniaKonferencji=@idkonferencji)
  	IF EXISTS (SELECT DK.ID_DniaKonferencji
			   FROM ZamowienieSzczegolowe ZS
			   JOIN DzienKonferencji DK ON ZS.ID_DniaKonferencji=DK.ID_DniaKonferencji
			   GROUP BY DK.ID_DniaKonferencji
			   HAVING DK.ID_DniaKonferencji = @idkonferencji)
	SET @wykorzystane_miejsca = (SELECT SUM(ZS.LiczbaMiejsc)
							     FROM ZamowienieSzczegolowe ZS
							     JOIN DzienKonferencji DK ON ZS.ID_DniaKonferencji=DK.ID_DniaKonferencji
							     GROUP BY DK.ID_DniaKonferencji
							     HAVING DK.ID_DniaKonferencji = @idkonferencji)
	ELSE
		SET @wykorzystane_miejsca=0
	
  	SET @wolne_miejsca = @limit_miejsc - @wykorzystane_miejsca
  	
  	IF @potrzebne_miejsca > @wolne_miejsca 
  	BEGIN
        RAISERROR('Nie ma odpowiedniej ilosci wolnych miejsc.',16,1)
        ROLLBACK TRANSACTION
    END
		ELSE 
		BEGIN
			INSERT INTO ZamowienieSzczegolowe
			SELECT INS.ID_Zamowienia,INS.ID_DniaKonferencji,INS.LiczbaMiejsc FROM inserted INS
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
  						 WHERE WAR.ID_Warsztatu=@id_warsztatu)
	IF EXISTS (SELECT ZW.ID_Warsztatu
			   FROM ZamowienieWarsztatu ZW
			   GROUP BY ZW.ID_Warsztatu
			   HAVING ZW.ID_Warsztatu = @id_warsztatu)
	SET @wykorzystane_miejsca = (SELECT SUM(ZW.LiczbaMiejsc)
  								 FROM ZamowienieWarsztatu ZW
  								 GROUP BY ZW.ID_Warsztatu
  								 HAVING ZW.ID_Warsztatu = @id_warsztatu)
  	ELSE
  		SET @wykorzystane_miejsca=0
  		
  	SET @wolne_miejsca = @limit_miejsc - @wykorzystane_miejsca
  	
  	IF @potrzebne_miejsca > @wolne_miejsca
	BEGIN
      	RAISERROR('Nie ma odpowiedniej ilosci wolnych miejsc.',16,1)
      	ROLLBACK TRANSACTION
	END
		ELSE
		BEGIN
			INSERT INTO ZamowienieWarsztatu
			SELECT INS.ID_ZamSzczegolowego,INS.ID_Warsztatu,INS.LiczbaMiejsc,INS.StatusRezerwacji FROM inserted INS
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
CREATE TRIGGER Trigger_akt_dod_dozaplaty_zamszczeg
ON ZamowienieSzczegolowe
AFTER INSERT
AS BEGIN
	DECLARE @id_zamowienia AS INT
	DECLARE @id_zam_szczeg AS INT
	DECLARE @dotychczasowa_oplata AS MONEY

	SET @id_zam_szczeg = (SELECT INS.ID_ZamSzczegolowego FROM inserted INS)
	SET @id_zamowienia = (SELECT INS.ID_Zamowienia FROM inserted INS)
	SET @dotychczasowa_oplata = (SELECT DoZapltay FROM Zamowienie ZAM WHERE ZAM.ID_Zamowienia=@id_zamowienia)
	
	UPDATE Zamowienie
	SET DoZapltay = @dotychczasowa_oplata + dbo.kwota_za_zam_szczeg(@id_zam_szczeg)
	WHERE ID_Zamowienia=@id_zamowienia		
END
GO

--
CREATE TRIGGER Trigger_akt_dod_dozaplaty_warsztat
ON ZamowienieWarsztatu
AFTER INSERT
AS BEGIN
	DECLARE @dotychczasowa_oplata AS MONEY
	DECLARE @id_zamowienia AS INT
	DECLARE @id_zam_warsztatu AS INT
	SET @id_zam_warsztatu = (SELECT INS.ID_ZamowieniaWarsztatu FROM inserted INS)
	SET @id_zamowienia = (SELECT ZS.ID_Zamowienia
						  FROM ZamowienieSzczegolowe ZS
						  JOIN ZamowienieWarsztatu ZW ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
						  WHERE ZW.ID_ZamowieniaWarsztatu = @id_zam_warsztatu)

	SET @dotychczasowa_oplata = (SELECT DoZapltay FROM Zamowienie ZAM WHERE ZAM.ID_Zamowienia=@id_zamowienia)
	
	UPDATE Zamowienie
	SET DoZapltay = @dotychczasowa_oplata + dbo.kwota_za_zam_warsztatu(@id_zam_warsztatu)
	WHERE ID_Zamowienia=@id_zamowienia		
END
GO

-- 
CREATE TRIGGER Trigger_usun_zamszczeg
ON ZamowienieSzczegolowe
INSTEAD OF DELETE
AS
BEGIN 
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
		---- Aktualizacja kwoty DoZaplaty
		DECLARE @id_zamowienia INT
		DECLARE @dotychczasowa_oplata AS MONEY
		DECLARE @kwota_warsztaty AS MONEY
		DECLARE @kwota_zam_szczeg AS MONEY
		SET @id_zamowienia = (SELECT ID_Zamowienia FROM deleted)
		SET @dotychczasowa_oplata = (SELECT DoZapltay FROM Zamowienie ZAM WHERE ZAM.ID_Zamowienia=@id_zamowienia)
		SET @kwota_warsztaty = ISNULL((SELECT SUM(dbo.kwota_za_zam_warsztatu(ZW.ID_ZamowieniaWarsztatu))
						   			   FROM ZamowienieSzczegolowe ZS
									   JOIN ZamowienieWarsztatu ZW ON ZW.ID_ZamSzczegolowego=ZS.ID_ZamSzczegolowego
									   WHERE ZS.ID_ZamSzczegolowego=@id_zam_szczegolowego),0)
		SET @kwota_zam_szczeg = dbo.kwota_za_zam_szczeg(@id_zam_szczegolowego)
		
		UPDATE Zamowienie
		SET DoZapltay = @dotychczasowa_oplata - @kwota_warsztaty - @kwota_zam_szczeg
		WHERE ID_Zamowienia = @id_zamowienia
		
		---- Usuwanie odpowiednich rekordow
		DELETE FROM UczestnikWarsztatu 
		WHERE ID_ZamowieniaWarsztatu IN (SELECT ZW.ID_ZamowieniaWarsztatu
										 FROM ZamowienieWarsztatu ZW
										 JOIN ZamowienieSzczegolowe ZS ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
										 WHERE ZS.ID_ZamSzczegolowego = @id_zam_szczegolowego)
		DELETE FROM UczestnikKonferencji WHERE ID_ZamSzczegolowego = @id_zam_szczegolowego									 
		DELETE FROM ZamowienieWarsztatu WHERE ID_ZamSzczegolowego = @id_zam_szczegolowego
		DELETE FROM ZamowienieSzczegolowe WHERE ID_ZamSzczegolowego = @id_zam_szczegolowego
	END
END
GO

--
CREATE TRIGGER Trigger_czymozna_usunac_warsztat
ON ZamowienieWarsztatu
INSTEAD OF DELETE
AS
BEGIN 
	DECLARE @dzisiejsza_data DATE
	DECLARE @data_konferencji DATE
	DECLARE @id_zam_szczegolowego INT
	
	SET @id_zam_szczegolowego = (SELECT DISTINCT ID_ZamSzczegolowego FROM deleted)
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
		---- Aktualizacja kwoty DoZaplaty
		DECLARE @id_zamowienia INT
		DECLARE @dotychczasowa_oplata AS MONEY
		DECLARE @kwota AS MONEY
		DECLARE @id_zam_warsztatu AS MONEY
		SET @id_zamowienia = (SELECT ZAM.ID_Zamowienia
							  FROM Zamowienie ZAM
							  JOIN ZamowienieSzczegolowe ZS ON ZS.ID_Zamowienia=ZAM.ID_Zamowienia
							  WHERE ZS.ID_ZamSzczegolowego=@id_zam_szczegolowego)
		SET @dotychczasowa_oplata = (SELECT DoZapltay FROM Zamowienie ZAM WHERE ZAM.ID_Zamowienia=@id_zamowienia)
		SET @kwota = ISNULL((SELECT SUM(dbo.kwota_za_zam_warsztatu(@id_zam_warsztatu))
						     FROM ZamowienieWarsztatu ZW
						     WHERE ZW.ID_ZamowieniaWarsztatu IN (SELECT ID_ZamowieniaWarsztatu FROM deleted)),0)
		
		UPDATE Zamowienie
		SET DoZapltay = @dotychczasowa_oplata - @kwota
		WHERE ID_Zamowienia = @id_zamowienia
		
		---- Usuwanie odpowiednich rekordow
		IF ((SELECT COUNT(*) FROM deleted) = 1)
		BEGIN
			DELETE FROM UczestnikWarsztatu WHERE ID_ZamowieniaWarsztatu = (SELECT ID_ZamowieniaWarsztatu FROM deleted)
			DELETE FROM ZamowienieWarsztatu WHERE ID_ZamowieniaWarsztatu = (SELECT ID_ZamowieniaWarsztatu FROM deleted)
		END ELSE 
		BEGIN
			DELETE FROM UczestnikWarsztatu WHERE ID_ZamowieniaWarsztatu IN (SELECT ZW.ID_ZamowieniaWarsztatu
																			FROM ZamowienieWarsztatu ZW
																			JOIN ZamowienieSzczegolowe ZS ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
																			WHERE ZS.ID_ZamSzczegolowego=@id_zam_szczegolowego)
			DELETE FROM ZamowienieWarsztatu WHERE ID_ZamowieniaWarsztatu IN (SELECT ZW.ID_ZamowieniaWarsztatu
																			FROM ZamowienieWarsztatu ZW
																			JOIN ZamowienieSzczegolowe ZS ON ZS.ID_ZamSzczegolowego=ZW.ID_ZamSzczegolowego
																			WHERE ZS.ID_ZamSzczegolowego=@id_zam_szczegolowego)
		END
	END
END
GO

--
CREATE TRIGGER Trigger_wplata
ON Zamowienie
AFTER UPDATE
AS
BEGIN
	DECLARE @do_zaplaty MONEY
	DECLARE @zaplacono MONEY
	DECLARE @id_zamowienia INT
	
	SET @id_zamowienia = (SELECT ID_Zamowienia FROM inserted)
	
	SET @do_zaplaty = (SELECT ZAM.DoZapltay
					   FROM Zamowienie ZAM
					   WHERE ZAM.ID_Zamowienia = @id_zamowienia)

	SET @zaplacono = (SELECT ZAM.Zaplacono
					  FROM Zamowienie ZAM
					  WHERE ZAM.ID_Zamowienia = @id_zamowienia)	
	IF (@zaplacono = @do_zaplaty) 
	BEGIN
		UPDATE Zamowienie
		SET StatusPlatnosci = 2
		WHERE ID_Zamowienia = @id_zamowienia
	END
END
GO

--
CREATE TRIGGER Trigger_zmiana_statusu
ON Konferencja
AFTER UPDATE
AS
BEGIN
	DECLARE @status SMALLINT
	DECLARE @id_konferencji INT
	SET @id_konferencji = (SELECT ID_Konferencji FROM inserted)
	SET @status = (SELECT StatusKonferencji FROM Konferencja WHERE ID_Konferencji = @id_konferencji)
	
	IF(@status = 2) 
	BEGIN
		UPDATE Zamowienie 
		SET StatusPlatnosci = 3
		WHERE ID_Zamowienia IN (SELECT ZAM.ID_Zamowienia
								FROM Konferencja KON
								JOIN Zamowienie ZAM ON KON.ID_Konferencji=ZAM.ID_Konferencji)
		UPDATE Zamowienie
		SET StatusRejestracji = 3
		WHERE ID_Zamowienia IN (SELECT ZAM.ID_Zamowienia
								FROM Konferencja KON
								JOIN Zamowienie ZAM ON KON.ID_Konferencji=ZAM.ID_Konferencji)
	END
END
GO

--
CREATE TRIGGER Trigger_dodaj_uczestnika_kon
ON UczestnikKonferencji
AFTER INSERT
AS 
BEGIN
	DECLARE @limit AS SMALLINT
	DECLARE @wprowadzone_miejsca AS SMALLINT
	DECLARE @id_zam_szcz AS INT
	
	SET @id_zam_szcz = (SELECT ID_ZamSzczegolowego FROM inserted)
	
	SET @limit = (SELECT ZS.LiczbaMiejsc
				  FROM ZamowienieSzczegolowe ZS
				  WHERE ZS.ID_ZamSzczegolowego=@id_zam_szcz)
				  
	SET @wprowadzone_miejsca = (SELECT COUNT(*)
								FROM UczestnikKonferencji UK
								WHERE UK.ID_ZamSzczegolowego=@id_zam_szcz)
								
	IF(@wprowadzone_miejsca > @limit)
	BEGIN
		RAISERROR('Przekroczono liczbe osob zadeklarowana w rejestracji.',16,1)
        ROLLBACK TRANSACTION
	END
	
END
GO

--
CREATE TRIGGER Trigger_dodaj_uczestnika_war
ON UczestnikWarsztatu
AFTER INSERT
AS 
BEGIN
	DECLARE @limit AS SMALLINT
	DECLARE @wprowadzone_miejsca AS SMALLINT
	DECLARE @id_zam_war AS INT
	
	SET @id_zam_war = (SELECT ID_ZamowieniaWarsztatu FROM inserted)
	
	SET @limit = (SELECT ZW.LiczbaMiejsc
				  FROM ZamowienieWarsztatu ZW
				  WHERE ZW.ID_ZamowieniaWarsztatu=@id_zam_war)
				  
	SET @wprowadzone_miejsca = (SELECT COUNT(*)
								FROM UczestnikWarsztatu UW
								WHERE UW.ID_ZamowieniaWarsztatu = @id_zam_war)
								
	IF(@wprowadzone_miejsca > @limit)
	BEGIN
		RAISERROR('Przekroczono liczbe osob zadeklarowana w rejestracji.',16,1)
        ROLLBACK TRANSACTION
	END
	
END
