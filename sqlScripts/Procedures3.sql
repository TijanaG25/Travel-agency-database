---Kreiranje rezervacije---
CREATE PROCEDURE kreiraj_rezervaciju(
    idKorisnika INT,
    idTure INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    noviBrojRezervacije INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Korisnik k
        WHERE k.Id = idKorisnika AND k.Aktivan = TRUE
    ) THEN
        RAISE EXCEPTION
            'Korisnik ne postoji ili nije aktivan';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_tura tt
        WHERE tt.Id = idTure AND tt.Aktivan = TRUE AND tt.Datum_pocetka > CURRENT_TIMESTAMP
    ) THEN
        RAISE EXCEPTION 'Izabrana turistička tura ne postoji, nije aktivna ili je već počela';
    END IF;
    IF postoji_preklapanje_termina(idKorisnika, idTure) THEN
        RAISE EXCEPTION 'Korisnik već ima aktivnu rezervaciju za turističku turu koja se vremenski preklapa';
    END IF;
    noviBrojRezervacije := generisi_broj_rezervacije();
    INSERT INTO Rezervacija (
        Broj_rezervacije,
        Id_nosioca_rezervacije,
        Status_placanja,
        idTure,
        Aktivan,
        Status_rezervacije
    )
    VALUES (
        noviBrojRezervacije,
        idKorisnika,
        'Nije plaćena',
        idTure,
        TRUE,
        'Aktivna'
    );
END;
$$;
---Dodavanje nosioca kao putnika---
CREATE PROCEDURE dodaj_nosioca_kao_putnika(
    idKorisnika INT,
    idRezervacije INT
	)
LANGUAGE plpgsql
AS $$
DECLARE
    idPutnika INT;
    idTure INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Korisnik k
        WHERE k.Id = idKorisnika AND k.Aktivan = TRUE
    ) THEN
        RAISE EXCEPTION 'Korisnik ne postoji ili nije aktivan';
    END IF;
    SELECT r.idTure INTO idTure
    FROM Rezervacija r
    WHERE r.Id = idRezervacije AND r.Id_nosioca_rezervacije = idKorisnika AND r.Aktivan = TRUE AND r.Status_rezervacije = 'Aktivna';
    IF idTure IS NULL THEN
        RAISE EXCEPTION 'Rezervacija ne postoji, nije aktivna ili korisnik nije njen nosilac';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Putnik p JOIN Korisnik k ON p.Jmbg = k.Jmbg
					JOIN Rezervacija_putnik rp ON rp.idPutnika = p.Id
        WHERE k.Id = idKorisnika AND rp.idRezervacije = idRezervacije
    ) THEN
        RAISE EXCEPTION 'Korisnik je već dodat kao putnik na ovoj rezervaciji';
    END IF;
    SELECT p.Id INTO idPutnika
    FROM Putnik p JOIN Korisnik k ON p.Jmbg = k.Jmbg
    WHERE k.Id = idKorisnika AND p.Aktivan = TRUE;
    IF idPutnika IS NULL THEN
        INSERT INTO Putnik ( Ime,Prezime,Broj_telefona,Jmbg,Id_mestaStanovanja,Adresa_stanovanja,Aktivan,Saglasnost)
        SELECT k.Ime,k.Prezime,k.Broj_telefona,k.Jmbg,k.Id_mestaStanovanja,k.Adresa_stanovanja,TRUE,NULL
        FROM Korisnik k
        WHERE k.Id = idKorisnika
        RETURNING Id INTO idPutnika;
    END IF;
    INSERT INTO Rezervacija_putnik (
        idPutnika,
        idRezervacije,
        Status_putnika
    )
    VALUES (
        idPutnika,
        idRezervacije,
        'Nosilac'
    );
END;
$$;
---Dodavanje putnika---
CREATE OR REPLACE PROCEDURE dodaj_putnika_u_rezervaciju(
    idKorisnika INT,
    idRezervacije INT,
    ime VARCHAR,
    prezime VARCHAR,
    brojTelefona VARCHAR,
    jmbg CHAR(13),
    idMestaStanovanja INT,
    adresaStanovanja VARCHAR,
    statusPutnika status_putnika,
    saglasnost VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    idPutnika INT;
    idTure INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Korisnik k
        WHERE k.Id = idKorisnika AND k.Aktivan = TRUE
    ) THEN
        RAISE EXCEPTION 'Korisnik ne postoji ili nije aktivan';
    END IF;
    SELECT r.idTure INTO idTure
    FROM Rezervacija r
    WHERE r.Id = idRezervacije AND r.Id_nosioca_rezervacije = idKorisnika AND r.Aktivan = TRUE AND r.Status_rezervacije = 'Aktivna';
    IF idTure IS NULL THEN
        RAISE EXCEPTION 'Rezervacija ne postoji, nije aktivna ili korisnik nije njen nosilac';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Putnik p JOIN Rezervacija_putnik rp ON p.Id = rp.idPutnika
        WHERE p.Jmbg = jmbg AND rp.idRezervacije = idRezervacije
    ) THEN
        RAISE EXCEPTION 'Ovaj putnik je već dodat na izabranu rezervaciju';
    END IF;
    IF postoji_putnik(jmbg) THEN
        SELECT p.Id INTO idPutnika
        FROM Putnik p
        WHERE p.Jmbg = jmbg AND p.Aktivan = TRUE;
        IF idPutnika IS NULL THEN
            RAISE EXCEPTION 'Putnik postoji, ali nije aktivan';
        END IF;
        IF NOT punoletan(jmbg) THEN
            IF NOT EXISTS (
                SELECT 1
                FROM Putnik p
                WHERE p.Id = idPutnika AND p.Saglasnost IS NOT NULL AND TRIM(p.Saglasnost) <> ''
            ) AND (saglasnost IS NULL OR TRIM(saglasnost) = '') THEN
                RAISE EXCEPTION 'Putnik je maloletan i potrebna je saglasnost roditelja ili zakonskog staratelja';
            END IF;
            IF saglasnost IS NOT NULL AND TRIM(saglasnost) <> '' THEN
                UPDATE Putnik
                SET Saglasnost = TRIM(saglasnost), Poslednja_izmena = CURRENT_TIMESTAMP
                WHERE Id = idPutnika;
            END IF;
        END IF;
    ELSE
        IF NOT punoletan(jmbg) AND (saglasnost IS NULL OR TRIM(saglasnost) = '') THEN
            RAISE EXCEPTION 'Putnik je maloletan i potrebna je saglasnost roditelja ili zakonskog staratelja';
        END IF;
        INSERT INTO Putnik (Ime,Prezime,Broj_telefona,Jmbg,Id_mestaStanovanja,Adresa_stanovanja,Aktivan,Saglasnost)
        VALUES (TRIM(ime),TRIM(prezime),TRIM(brojTelefona),jmbg,idMestaStanovanja,TRIM(adresaStanovanja),TRUE,
            CASE
                WHEN punoletan(jmbg) THEN NULL
                ELSE TRIM(saglasnost)
            END
        )
        RETURNING Id INTO idPutnika;
    END IF;
    INSERT INTO Rezervacija_putnik (idPutnika,idRezervacije,Status_putnika)
    VALUES (idPutnika,idRezervacije,statusPutnika);
END;
$$;
---Otkazivanje rezervacije---
CREATE PROCEDURE otkazi_rezervaciju(
    id_rezervacije INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT moze_se_otkazati(id_rezervacije) THEN
        RAISE EXCEPTION
            'Rezervacija ne postoji ili više nije moguće otkazati rezervaciju';
    END IF;
    UPDATE Rezervacija
    SET Aktivan = FALSE,
        Status_rezervacije = 'Otkazana',
        Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = id_rezervacije;
END;
$$;
---Potvrda uplate---
CREATE PROCEDURE potvrdi_uplatu(
    idRezervacije INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Rezervacija r
        WHERE r.Id = idRezervacije
    ) THEN
        RAISE EXCEPTION 'Rezervacija sa ID % ne postoji',idRezervacije;
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Rezervacija r
        WHERE r.Id = idRezervacije AND r.Aktivan = TRUE AND r.Status_rezervacije = 'Aktivna'
    ) THEN
        RAISE EXCEPTION 'Uplata nije moguća za ovu rezervaciju';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Rezervacija r
        WHERE r.Id = idRezervacije AND r.Status_placanja = 'Plaćena'
    ) THEN
        RAISE EXCEPTION 'Rezervacija je već plaćena';
    END IF;
    UPDATE Rezervacija
    SET Status_placanja = 'Plaćena',
		Datum_uplate = CURRENT_TIMESTAMP,
        Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idRezervacije;
END;
$$;

---Uklanjanje putnika---
CREATE PROCEDURE ukloni_putnika_sa_rezervacije(
    rezervacijaId INT,
    putnikId INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    datumPocetkaTure TIMESTAMP;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Rezervacija_putnik rp
        WHERE rp.idRezervacije = rezervacijaId AND rp.idPutnika = putnikId
    ) THEN
        RAISE EXCEPTION 'Putnik nije prijavljen na izabranu rezervaciju';
    END IF;
    SELECT tt.Datum_pocetka INTO datumPocetkaTure
    FROM Rezervacija r JOIN Turisticka_tura tt ON r.idTure = tt.Id
    WHERE r.Id = rezervacijaId AND r.Aktivan = TRUE AND r.Status_rezervacije = 'Aktivna';
    IF datumPocetkaTure IS NULL THEN
        RAISE EXCEPTION 'Rezervacija ne postoji ili nije aktivna';
    END IF;
    IF CURRENT_TIMESTAMP > datumPocetkaTure - INTERVAL '7 days' THEN
        RAISE EXCEPTION 'Putnik se može ukloniti najkasnije 7 dana pre početka putovanja';
    END IF;
    DELETE FROM Rezervacija_putnik
    WHERE idRezervacije = rezervacijaId AND idPutnika = putnikId;
END;
$$;
---Izmena putnika---
CREATE PROCEDURE izmeni_putnika(
    putnikId INT,
    imePutnika VARCHAR(30),
    prezimePutnika VARCHAR(50),
    brojTelefonaPutnika VARCHAR(15),
    jmbgPutnika CHAR(13),
    mestoStanovanjaId INT,
    adresaStanovanjaPutnika VARCHAR(50),
    saglasnostPutnika VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
	IF imePutnika IS NULL OR TRIM(imePutnika) = '' THEN
    	RAISE EXCEPTION 'Ime putnika ne može biti prazno';
	END IF;
	IF prezimePutnika IS NULL OR TRIM(prezimePutnika) = '' THEN
   	 RAISE EXCEPTION 'Prezime putnika ne može biti prazno';
	END IF;
	IF jmbgPutnika IS NULL OR TRIM(jmbgPutnika) = '' THEN
   	 RAISE EXCEPTION 'JMBG putnika ne može biti prazan';
	END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Putnik p
        WHERE p.Id = putnikId AND p.Aktivan = TRUE
    ) THEN
        RAISE EXCEPTION 'Putnik sa ID % ne postoji ili nije aktivan',putnikId;
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Putnik p
        WHERE p.Jmbg = jmbgPutnika AND p.Id <> putnikId
    ) THEN
        RAISE EXCEPTION 'Putnik sa JMBG % već postoji', jmbgPutnika;
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Mesto m
        WHERE m.Id = mestoStanovanjaId AND m.Aktivan = TRUE
    ) THEN
        RAISE EXCEPTION 'Izabrano mesto stanovanja ne postoji ili nije aktivno';
    END IF;
    UPDATE Putnik
    SET Ime = TRIM(imePutnika),
        Prezime = TRIM(prezimePutnika),
        Broj_telefona = TRIM(brojTelefonaPutnika),
        Jmbg = jmbgPutnika,
        Id_mestaStanovanja = mestoStanovanjaId,
        Adresa_stanovanja = TRIM(adresaStanovanjaPutnika),
        Saglasnost = TRIM(saglasnostPutnika),
        Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = putnikId;
END;
$$;
---Deaktivacija putnika--
CREATE PROCEDURE deaktiviraj_putnika(
    putnikId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Putnik p
        WHERE p.Id = putnikId AND p.Aktivan = TRUE
    ) THEN
        RAISE EXCEPTION 'Putnik sa ID % ne postoji ili je već deaktiviran',putnikId;
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Rezervacija_putnik rp JOIN Rezervacija r ON rp.idRezervacije = r.Id
        WHERE rp.idPutnika = putnikId AND r.Aktivan = TRUE AND r.Status_rezervacije = 'Aktivna'
    ) THEN
        RAISE EXCEPTION 'Putnik ne može biti deaktiviran jer ima aktivnu rezervaciju';
    END IF;
    UPDATE Putnik
    SET Aktivan = FALSE,Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = putnikId;
END;
$$;

---Aktivacija putnika---
CREATE PROCEDURE aktiviraj_putnika(
    putnikId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Putnik p
        WHERE p.Id = putnikId AND p.Aktivan = FALSE
    ) THEN
        RAISE EXCEPTION'Putnik sa ID % ne postoji ili je već aktivan',putnikId;
    END IF;
    UPDATE Putnik
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = putnikId;
END;
$$;