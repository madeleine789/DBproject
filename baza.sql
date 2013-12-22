

CREATE DATABASE Konferencje
GO
USE Konferencje
GO

CREATE TABLE ProgiCenowe ( 
	ID_ProguCenowego INT PRIMARY KEY NOT NULL,
	ProcentCeny SMALLINT NOT NULL CHECK(ProcentCeny > 0),
	Opis TEXT NOT NULL
)

INSERT INTO ProgiCenowe (ID_ProguCenowego,ProcentCeny,Opis) VALUES (1, 90,'3 miesiace przed')
GO
INSERT INTO ProgiCenowe (ID_ProguCenowego,ProcentCeny,Opis) VALUES (2, 100,'2 miesiace przed')
GO
INSERT INTO ProgiCenowe (ID_ProguCenowego,ProcentCeny,Opis) VALUES (3, 110,'1 miesiac przed')
GO

CREATE TABLE StatusKonferencji (
	ID_StatusuKonferencji SMALLINT PRIMARY KEY NOT NULL,
	StatusKonferencji NVARCHAR(15) NOT NULL
)

INSERT INTO StatusKonferencji (ID_StatusuKonferencji,StatusKonferencji) VALUES (1, 'W trakcie')
GO
INSERT INTO StatusKonferencji (ID_StatusuKonferencji,StatusKonferencji) VALUES (2, 'Zamkniety')
GO
INSERT INTO StatusKonferencji (ID_StatusuKonferencji,StatusKonferencji) VALUES (3, 'Zakonczony')
GO
INSERT INTO StatusKonferencji (ID_StatusuKonferencji,StatusKonferencji) VALUES (4, 'Skompletowany')
GO

CREATE TABLE StatusRejestracji (
	ID_StatusuRejestracji SMALLINT PRIMARY KEY NOT NULL,
	StatusRejestracji NVARCHAR(15) NOT NULL
)

INSERT INTO StatusRejestracji (ID_StatusuRejestracji,StatusRejestracji) VALUES (1, 'W trakcie')
GO
INSERT INTO StatusRejestracji (ID_StatusuRejestracji,StatusRejestracji) VALUES (2, 'Zakonczona')
GO
INSERT INTO StatusRejestracji (ID_StatusuRejestracji,StatusRejestracji) VALUES (3, 'Anulowana')
GO

CREATE TABLE StatusPlatnosci (
	ID_StatusuPlatnosci SMALLINT PRIMARY KEY NOT NULL,
	StatusPlatnosci NVARCHAR(15) NOT NULL
)

INSERT INTO StatusPlatnosci (ID_StatusuPlatnosci,StatusPlatnosci) VALUES (1, 'Niezaplacone')
GO
INSERT INTO StatusPlatnosci (ID_StatusuPlatnosci,StatusPlatnosci) VALUES (2, 'Zaplacone')
GO
INSERT INTO StatusPlatnosci (ID_StatusuPlatnosci,StatusPlatnosci) VALUES (3, 'Zwrot')
GO
INSERT INTO StatusPlatnosci (ID_StatusuPlatnosci,StatusPlatnosci) VALUES (4, 'Anulowane')
GO

----------------------------------------------------------------------------------------

CREATE TABLE DaneAdresowe (
	ID_DanychAdresowych INT IDENTITY(1,1) PRIMARY KEY  NOT NULL ,
	Adres NVARCHAR(60) NOT NULL ,
	Miasto NVARCHAR(15) NOT NULL ,
	KodPocztowy NVARCHAR(10) NOT NULL ,
	Kraj NVARCHAR(15) NOT NULL ,
)

	
CREATE TABLE Klient (
	ID_Klienta INT IDENTITY(1,1) PRIMARY KEY  NOT NULL ,
	CzyFirma BIT NOT NULL DEFAULT 0,
)
	
CREATE TABLE Osoba (
	ID_Osoby INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	ID_Klienta INT FOREIGN KEY REFERENCES Klient(ID_Klienta) NULL,
	ID_DanychAdresowych INT FOREIGN KEY REFERENCES DaneAdresowe(ID_DanychAdresowych) NULL ,
	Imie NVARCHAR(20) NOT NULL ,
	Nazwisko NVARCHAR(20) NOT NULL ,
	NrAlbumu NVARCHAR(6) NULL,
	Telefon NVARCHAR(15) NULL,
	Email NVARCHAR(32) NULL

)
		
CREATE TABLE Firma (
	NIP INT PRIMARY KEY NOT NULL,
	ID_Klienta INT UNIQUE FOREIGN KEY REFERENCES Klient(ID_Klienta) NOT NULL,
	ID_DanychAdresowych INT UNIQUE FOREIGN KEY REFERENCES DaneAdresowe(ID_DanychAdresowych) NOT NULL,
	NazwaFirmy NVARCHAR(40) NOT NULL,
	Telefon NVARCHAR(15) NULL,
	Fax NVARCHAR(24) NULL,
	Email NVARCHAR(32) NULL
	
)

CREATE TABLE Pracownik (
	NIP INT UNIQUE FOREIGN KEY REFERENCES Firma(NIP) NOT NULL,
	ID_Osoby INT UNIQUE FOREIGN KEY REFERENCES Osoba(ID_Osoby) NOT NULL,
	PRIMARY KEY(ID_Osoby, NIP)
)

CREATE TABLE TematKonferencji (
	ID_TematuKonferencji INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	Opis TEXT NOT NULL
)

CREATE TABLE Konferencja (
	ID_Konferencji INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	ID_TematuKonferencji INT FOREIGN KEY REFERENCES TematKonferencji(ID_TematuKonferencji) NOT NULL,
	DataRozpoczecia DATE NOT NULL,
	DataZakonczenia DATE NOT NULL,
	Cena MONEY NOT NULL CHECK(Cena > 0),
	StatusKonferencji SMALLINT FOREIGN KEY REFERENCES StatusKonferencji(ID_StatusuKonferencji) NOT NULL,
)

CREATE TABLE DzienKonferencji (
	ID_DniaKonferencji INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	ID_Konferencji INT FOREIGN KEY REFERENCES Konferencja(ID_Konferencji) NOT NULL,
	DzienKonferencji DATE NOT NULL,
	LimitMiejsc SMALLINT NOT NULL CHECK(LimitMiejsc > 0)
)

CREATE TABLE TematWarsztatu (
	ID_TematuWarsztatu INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	Opis TEXT NOT NULL
)

CREATE TABLE Warsztat (
	ID_Warsztatu INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	ID_TematuWarsztatu INT FOREIGN KEY REFERENCES TematWarsztatu(ID_TematuWarsztatu) NOT NULL,
	ID_DniaKonferencji INT FOREIGN KEY REFERENCES DzienKonferencji(ID_DniaKonferencji) NOT NULL,
	Cena MONEY NOT NULL CHECK(Cena > 0),
	LimitMIejsc SMALLINT NOT NULL CHECK(LimitMiejsc > 0),
	GodzinaRozpoczecia TIME NOT NULL,
	GodzinaZakonczenia TIME NOT NULL
	
)

CREATE TABLE Zamowienie (
	ID_Zamowienia INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	ID_Klienta INT FOREIGN KEY REFERENCES Klient(ID_Klienta) NOT NULL,
	ID_Konferencji INT FOREIGN KEY REFERENCES Konferencja(ID_Konferencji) NOT NULL,
	DataZlozeniaZamowienia DATE NOT NULL,
	StatusRejestracji SMALLINT FOREIGN KEY REFERENCES StatusRejestracji(ID_StatusuRejestracji) NOT NULL,
	StatusRezerwacji BIT NOT NULL,
	DoZapltay MONEY NOT NULL DEFAULT 0,
	Zaplacono MONEY NOT NULL DEFAULT 0,
	TerminPlatnosci DATE NOT NULL,
	StatusPlatnosci SMALLINT FOREIGN KEY REFERENCES StatusPlatnosci(ID_StatusuPlatnosci) NOT NULL,
)

CREATE TABLE ZamowienieSzczegolowe (
	ID_ZamSzczegolowego INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	ID_Zamowienia INT FOREIGN KEY REFERENCES Zamowienie(ID_Zamowienia) NOT NULL,
	ID_DniaKonferencji INT FOREIGN KEY REFERENCES DzienKonferencji(ID_DniaKonferencji) NOT NULL,
	LiczbaMiejsc SMALLINT NOT NULL CHECK(LiczbaMiejsc > 0)
)

CREATE TABLE ZamowienieWarsztatu (
	ID_ZamowieniaWarsztatu INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	ID_ZamSzczegolowego INT FOREIGN KEY REFERENCES ZamowienieSzczegolowe(ID_ZamSzczegolowego) NOT NULL,
	ID_Warsztatu INT FOREIGN KEY REFERENCES Warsztat(ID_Warsztatu) NOT NULL,
	LiczbaMiejsc SMALLINT NOT NULL CHECK(LiczbaMiejsc > 0),
	StatusRezerwacji BIT NOT NULL
)

CREATE TABLE UczestnikKonferencji (
	ID_UczestnikaKonferencji INT IDENTITY(1,1) PRIMARY KEY  NOT NULL,
	ID_Osoby INT FOREIGN KEY REFERENCES Osoba(ID_Osoby) NOT NULL,
	ID_ZamSzczegolowego INT FOREIGN KEY REFERENCES ZamowienieSzczegolowe(ID_ZamSzczegolowego) NOT NULL,
)

CREATE TABLE UczestnikWarsztatu (
	ID_ZamowieniaWarsztatu INT FOREIGN KEY REFERENCES ZamowienieWarsztatu(ID_ZamowieniaWarsztatu) NOT NULL,
	ID_UczestnikaKonferencji INT FOREIGN KEY REFERENCES UczestnikKonferencji(ID_UczestnikaKonferencji) NOT NULL,
	PRIMARY KEY (ID_UczestnikaKonferencji, ID_ZamowieniaWarsztatu)

)
GO
----------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE nowy_adres
	@Adres NVARCHAR(45),
	@KodPocztowy NVARCHAR(10),
	@Miasto NVARCHAR(25) ,
	@Kraj NVARCHAR(25)
	
AS
BEGIN

	SET NOCOUNT ON;
		INSERT INTO DaneAdresowe 
		VALUES(@Adres,@Miasto,@KodPocztowy,@Kraj)
END
GO

CREATE PROCEDURE dodaj_klienta_prywatnego

	@Imie NVARCHAR(20),
	@Nazwisko NVARCHAR(20),
	@NrAlbumu NVARCHAR(6) = null,
	@Telefon NVARCHAR(25) = null,
	@Email NVARCHAR(45) = null,
	@Adres NVARCHAR(60),
	@Miasto NVARCHAR(15),
	@KodPocztowy NVARCHAR(10),
	@Kraj NVARCHAR(15)

AS
BEGIN

	SET NOCOUNT ON;
	declare @ID_Osoby as int;
	declare @ID_Klienta as int;
	declare @ID_DanychAdresowych  as int;
	
	begin try
		begin tran 

		execute nowy_adres @Adres, @Miasto, @KodPocztowy, @Kraj;
		set @ID_DanychAdresowych = @@IDENTITY;
		
		INSERT INTO Klient VALUES(0);
		set @ID_Klienta = @@IDENTITY;
		
		INSERT INTO Osoba
		VALUES(@ID_Klienta,@ID_DanychAdresowych, @Imie, @Nazwisko, @NrAlbumu, @Telefon, @Email);
		COMMIT TRAN
	end try
	begin catch
		declare @error as varchar(127)
		set @error = (Select ERROR_MESSAGE())
		RAISERROR('Nie mozna dodac osoby-klienta, blad danych. %s', 16, 1, @error);
		ROLLBACK TRAN
	end catch
END
GO


GO
CREATE PROCEDURE dodaj_osobe_jako_klienta
	@ID_Osoby int
		
AS
BEGIN

	SET NOCOUNT ON;
		IF (select Osoba.ID_Klienta from Osoba where Osoba.ID_Osoby = @ID_Osoby) is null
		BEGIN
			INSERT INTO Klient VALUES (0)
			UPDATE Osoba
			SET ID_Klienta = @@IDENTITY
			WHERE Osoba.ID_Osoby = @ID_Osoby 
		END
		ELSE
		BEGIN
			RAISERROR('Ta osoba jest juz klientem. ', 16, 1);
		END
		
END
GO