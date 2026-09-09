CREATE TABLE Uloga(
Id SERIAL PRIMARY KEY,
Naziv VARCHAR(50) NOT NULL CHECK (TRIM(Naziv) <> ''),
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL
);
CREATE TABLE Mesto(
Id SERIAL PRIMARY KEY,
Naziv VARCHAR(50) NOT NULL CHECK (TRIM(Naziv) <> ''),
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL
);
CREATE TABLE Korisnik(
Id SERIAL PRIMARY KEY,
Ime VARCHAR(30) NOT NULL CHECK (TRIM(Ime) <> ''),
Prezime VARCHAR(50) NOT NULL CHECK (TRIM(Prezime) <> ''),
Email VARCHAR(50) NOT NULL UNIQUE CHECK( Email Like '%@%'),
Lozinka VARCHAR(255) NOT NULL,
Broj_telefona VARCHAR(15) NOT NULL CHECK (Broj_telefona ~ '^[0-9+ -]+$'),
Jmbg CHAR(13) NOT NULL UNIQUE CHECK (Jmbg ~ '^[0-9]{13}$'),
Id_mestaStanovanja INT NOT NULL,
Adresa_stanovanja VARCHAR(50) NOT NULL CHECK (TRIM(Adresa_stanovanja) <> ''),
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL,
Id_uloge INT NOT NULL,
FOREIGN KEY (Id_mestaStanovanja) REFERENCES Mesto (Id),
FOREIGN KEY (Id_uloge) REFERENCES Uloga (Id)
);
CREATE TABLE Smestaj(
Id SERIAL PRIMARY KEY,
Naziv VARCHAR(50) NOT NULL CHECK (TRIM(Naziv) <> ''),
Vrsta VARCHAR(50) NOT NULL CHECK (TRIM(Vrsta) <> ''),
Id_mesta INT NOT NULL,
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL,
FOREIGN KEY (Id_mesta) REFERENCES Mesto (Id)
);
CREATE TABLE Prevoz(
Id SERIAL PRIMARY KEY,
Naziv VARCHAR(50) NOT NULL CHECK (TRIM(Naziv) <> ''),
Vrsta VARCHAR(50) NOT NULL CHECK (TRIM(Vrsta) <> ''),
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL
);
CREATE TABLE Destinacija(
Id SERIAL PRIMARY KEY,
Naziv VARCHAR(50) NOT NULL CHECK (TRIM(Naziv) <> ''),
Opis VARCHAR(255) NOT NULL CHECK (TRIM(Opis) <> ''),
Slika VARCHAR(255) NULL,
Kategorija VARCHAR(50) NOT NULL CHECK (TRIM(Kategorija) <> ''),
Id_mesta INT NOT NULL,
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL,
FOREIGN KEY (Id_mesta) REFERENCES Mesto (Id)
);
CREATE TABLE Turisticka_organizacija(
Id SERIAL PRIMARY KEY,
Naziv VARCHAR(50) NOT NULL CHECK (TRIM(Naziv) <> ''),
Opis VARCHAR(255) NULL,
Email VARCHAR(50) NOT NULL UNIQUE CHECK( Email Like '%@%'),
Broj_telefona VARCHAR(15) NOT NULL CHECK (Broj_telefona ~ '^[0-9+ -]+$'),
idMenadzera INT NOT NULL,
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL,
FOREIGN KEY (idMenadzera) REFERENCES Korisnik (Id)
);
CREATE TABLE Turisticka_tura(
Id SERIAL PRIMARY KEY,
Datum_pocetka TIMESTAMP NOT NULL,
Datum_kraja TIMESTAMP NOT NULL,
Cena NUMERIC(10,2) NOT NULL CHECK (Cena>0),
idPrevoza INT NOT NULL,
idSmestaja INT NULL,
Opis VARCHAR(255) NULL,
idOrganizacije INT NOT NULL,
idDestinacije INT NOT NULL,
BrojMesta INT NOT NULL CHECK (BrojMesta>0),
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL,
FOREIGN KEY (idPrevoza) REFERENCES Prevoz (Id),
FOREIGN KEY (idSmestaja) REFERENCES Smestaj (Id),
FOREIGN KEY (idOrganizacije) REFERENCES Turisticka_organizacija (Id),
FOREIGN KEY (idDestinacije) REFERENCES Destinacija (Id),
CHECK (Datum_kraja > Datum_pocetka)
);
CREATE TYPE status_placanja AS ENUM(
'Plaćena',
'Nije plaćena'
);
CREATE TYPE status_rezervacije AS ENUM(
'Realizovana',
'Otkazana',
'Aktivna'
);
CREATE TABLE Rezervacija(
Id SERIAL PRIMARY KEY,
Broj_rezervacije INT NOT NULL UNIQUE,
Id_nosioca_rezervacije INT NOT NULL,
Status_placanja status_placanja NOT NULL,
idTure INT NOT NULL,
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Status_rezervacije status_rezervacije NOT NULL,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Datum_uplate TIMESTAMP NULL,
Poslednja_izmena TIMESTAMP NULL,
FOREIGN KEY (Id_nosioca_rezervacije) REFERENCES Korisnik (Id),
FOREIGN KEY (idTure) REFERENCES Turisticka_tura (Id),
CHECK (
    (Status_placanja = 'Plaćena' AND Datum_uplate IS NOT NULL)
    OR
    (Status_placanja = 'Nije plaćena' AND Datum_uplate IS NULL)
),
CHECK (
    Datum_uplate IS NULL OR Datum_uplate >= Datum_kreiranja
)
);
CREATE TABLE Ocena(
Id SERIAL PRIMARY KEY,
idKorisnika INT NOT NULL,
idRezervacije INT NOT NULL,
Komentar VARCHAR(255) NULL,
Ocena INT NOT NULL CHECK (Ocena>0 AND Ocena<6),
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL,
UNIQUE(idKorisnika, idRezervacije),
FOREIGN KEY (idKorisnika) REFERENCES Korisnik (Id),
FOREIGN KEY (idRezervacije) REFERENCES Rezervacija (Id)
);
CREATE TABLE Putnik(
Id SERIAL PRIMARY KEY,
Ime VARCHAR(30) NOT NULL CHECK (TRIM(Ime) <> ''),
Prezime VARCHAR(50) NOT NULL CHECK (TRIM(Prezime) <> ''),
Broj_telefona VARCHAR(15) NOT NULL CHECK (Broj_telefona ~ '^[0-9+ -]+$'),
Jmbg CHAR(13) NOT NULL UNIQUE CHECK (Jmbg ~ '^[0-9]{13}$'),
Id_mestaStanovanja INT NOT NULL,
Adresa_stanovanja VARCHAR(50) NOT NULL CHECK (TRIM(Adresa_stanovanja) <> ''),
Aktivan BOOLEAN NOT NULL DEFAULT TRUE,
Saglasnost VARCHAR(255) NULL,
Datum_kreiranja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
Poslednja_izmena TIMESTAMP NULL,
FOREIGN KEY (Id_mestaStanovanja) REFERENCES Mesto (Id)
);
CREATE TYPE status_putnika AS ENUM(
'Nosilac',
'Saputnik'
);
CREATE TABLE Rezervacija_putnik(
idPutnika INT NOT NULL,
idRezervacije INT NOT NULL,
Status_putnika status_putnika NOT NULL,
PRIMARY KEY (idPutnika,idRezervacije),
FOREIGN KEY (idPutnika) REFERENCES Putnik (Id),
FOREIGN KEY (idRezervacije) REFERENCES Rezervacija (Id)
)