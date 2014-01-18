
--DROP ROLE Administrator
--DROP ROLE Rejestrator
--DROP ROLE Kontroler
--DROP ROLE Raporter
--DROP ROLE Obs³uga
--DROP ROLE Klient

CREATE ROLE Administrator AUTHORIZATION dbo
CREATE ROLE Rejestrator AUTHORIZATION dbo
CREATE ROLE Kontroler AUTHORIZATION dbo
CREATE ROLE Raporter AUTHORIZATION dbo
CREATE ROLE Obs³uga AUTHORIZATION dbo
CREATE ROLE Klient AUTHORIZATION dbo

USE Konferencje
GRANT EXECUTE, SELECT, INSERT, DELETE, UPDATE ON SCHEMA::[dbo] TO [Administrator]
GRANT SELECT, INSERT, DELETE, UPDATE ON Konferencja TO [Rejestrator]
GRANT SELECT, INSERT, DELETE, UPDATE ON TematKonferencji TO [Rejestrator]
GRANT SELECT, INSERT, DELETE, UPDATE ON DzienKonferencji TO [Rejestrator]
GRANT SELECT, INSERT, DELETE, UPDATE ON Warsztat TO [Rejestrator]
GRANT SELECT, INSERT, DELETE, UPDATE ON TematWarsztatu TO [Rejestrator]
GRANT SELECT, INSERT, DELETE, UPDATE ON Zamowienie TO [Kontroler]
GRANT SELECT, INSERT, DELETE, UPDATE ON ZamowienieSzczegolowe TO [Kontroler]
GRANT SELECT, INSERT, DELETE, UPDATE ON ZamowienieWarsztatu TO [Kontroler]
GRANT SELECT, INSERT, DELETE, UPDATE ON StatusKonferencji TO [Kontroler]
GRANT SELECT, INSERT, DELETE, UPDATE ON StatusPlatnosci TO [Kontroler]
GRANT SELECT, INSERT, DELETE, UPDATE ON StatusRejestracji TO [Kontroler]
--GRANT EXECUTE ON kwota_za_zam_szczeg TO [Raporter]
--GRANT EXECUTE ON kwota_za_zam_warsztatu TO [Raporter]
--GRANT EXECUTE ON lista_osob_konferencja TO [Raporter]
--GRANT EXECUTE ON lista_osob_warsztat TO [Raporter]
--GRANT EXECUTE ON czy_student TO [Obsluga]
GRANT INSERT, UPDATE ON Osoba TO [Klient]
GRANT INSERT, UPDATE ON DaneAdresowe TO [Klient]
