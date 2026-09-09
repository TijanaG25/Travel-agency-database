---TABELA DESTINACIJA---
---dodaj_destinaciju---
CREATE PROCEDURE dodaj_destinaciju(
    nazivDestinacije VARCHAR(50),
    opisDestinacije VARCHAR(255),
    slikaDestinacije VARCHAR(255),
    kategorijaDestinacije VARCHAR(50),
    nazivMesta VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    idMesta INT;
BEGIN
    IF nazivDestinacije IS NULL OR TRIM(nazivDestinacije) = '' THEN
        RAISE EXCEPTION 'Naziv destinacije ne može biti prazan';
    END IF;
    IF opisDestinacije IS NULL OR TRIM(opisDestinacije) = '' THEN
        RAISE EXCEPTION 'Opis destinacije ne može biti prazan';
    END IF;
    IF kategorijaDestinacije IS NULL OR TRIM(kategorijaDestinacije) = '' THEN
        RAISE EXCEPTION 'Kategorija destinacije ne može biti prazna';
    END IF;
    IF nazivMesta IS NULL OR TRIM(nazivMesta) = '' THEN
        RAISE EXCEPTION 'Mesto destinacije ne može biti prazno';
	END IF;
	SELECT Id INTO idMesta
    FROM Mesto
    WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivMesta)) AND Aktivan = TRUE;
    IF idMesta IS NULL THEN
        CALL dodaj_mesto(TRIM(nazivMesta));
        SELECT Id INTO idMesta
        FROM Mesto
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivMesta)) AND Aktivan = TRUE;
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Destinacija
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivDestinacije)) AND
		Id_mesta=idMesta AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Destinacija već postoji';
    END IF;
    INSERT INTO Destinacija (Naziv,Opis,Slika,Kategorija,Id_mesta)
    VALUES (TRIM(nazivDestinacije),TRIM(opisDestinacije),TRIM(slikaDestinacije),TRIM(kategorijaDestinacije),idMesta);
END;
$$;
---izmeni_destinaciju---
CREATE PROCEDURE izmeni_destinaciju(
    idDestinacije INT,
    nazivDestinacije VARCHAR(50),
    opisDestinacije VARCHAR(255),
    slikaDestinacije VARCHAR(255),
    kategorijaDestinacije VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Destinacija
        WHERE Id = idDestinacije
    )
    THEN
        RAISE EXCEPTION 'Tražena destinacija ne postoji';
    END IF;
    IF nazivDestinacije IS NULL OR TRIM(nazivDestinacije) = '' THEN
        RAISE EXCEPTION 'Naziv destinacije ne može biti prazan';
    END IF;
    IF opisDestinacije IS NULL OR TRIM(opisDestinacije) = '' THEN
        RAISE EXCEPTION 'Opis destinacije ne može biti prazan';
    END IF;
    IF kategorijaDestinacije IS NULL OR TRIM(kategorijaDestinacije) = '' THEN
        RAISE EXCEPTION 'Kategorija destinacije ne može biti prazna';
    END IF;
    UPDATE Destinacija
    SET Naziv = TRIM(nazivDestinacije),
		Opis = TRIM(opisDestinacije),
        Slika = NULLIF(TRIM(slikaDestinacije), ''),
        Kategorija = TRIM(kategorijaDestinacije),
        Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idDestinacije;
END;
$$;
---deaktiviraj_destinaciju---
CREATE PROCEDURE deaktiviraj_destinaciju(
    idDestinacije INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Destinacija
        WHERE Id = idDestinacije
    )
    THEN
        RAISE EXCEPTION 'Tražena destinacija ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Destinacija
        WHERE Id = idDestinacije AND Aktivan = FALSE
    )
    THEN
        RAISE EXCEPTION 'Destinacija je već deaktivirana';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE idDestinacije = idDestinacije AND Aktivan = TRUE AND Datum_pocetka > CURRENT_TIMESTAMP
    )
    THEN
        RAISE EXCEPTION 'Destinacija ne može biti deaktivirana jer postoji aktivna turistička tura koja vodi na nju';
    END IF;
    UPDATE Destinacija
    SET Aktivan = FALSE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idDestinacije;
END;
$$;
---aktiviraj_destinaciju---
CREATE PROCEDURE aktiviraj_destinaciju(
    idDestinacije INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Destinacija
        WHERE Id = idDestinacije
    )
    THEN
        RAISE EXCEPTION 'Tražena destinacija ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Destinacija
        WHERE Id = idDestinacije AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Destinacija je već aktivna';
    END IF;
    UPDATE Destinacija
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idDestinacije;
END;
$$;
---TABELA TURISTICKA ORGANIZACIJA---
---dodaj_turisticku_organizaciju---
CREATE PROCEDURE dodaj_turisticku_organizaciju(
    nazivOrganizacije VARCHAR(50),
    opisOrganizacije VARCHAR(255),
    emailOrganizacije VARCHAR(50),
    brojTelefonaOrganizacije VARCHAR(15),
    imeMenadzera VARCHAR(30),
    prezimeMenadzera VARCHAR(50),
    emailMenadzera VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    idMenadzera INT;
BEGIN
    IF nazivOrganizacije IS NULL OR TRIM(nazivOrganizacije) = '' THEN
        RAISE EXCEPTION 'Naziv turističke organizacije ne može biti prazan';
    END IF;
    IF emailOrganizacije IS NULL OR TRIM(emailOrganizacije) = '' THEN
        RAISE EXCEPTION 'Email turističke organizacije ne može biti prazan';
    END IF;
    IF brojTelefonaOrganizacije IS NULL OR TRIM(brojTelefonaOrganizacije) = '' THEN
        RAISE EXCEPTION 'Broj telefona turističke organizacije ne može biti prazan';
    END IF;
    IF imeMenadzera IS NULL OR TRIM(imeMenadzera) = '' THEN
        RAISE EXCEPTION 'Ime menadžera ne može biti prazno';
    END IF;
    IF prezimeMenadzera IS NULL OR TRIM(prezimeMenadzera) = '' THEN
        RAISE EXCEPTION 'Prezime menadžera ne može biti prazno';
    END IF;
    IF emailMenadzera IS NULL OR TRIM(emailMenadzera) = '' THEN
        RAISE EXCEPTION 'Email menadžera ne može biti prazan';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivOrganizacije)) AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija sa nazivom "%" već postoji',nazivOrganizacije;
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE LOWER(TRIM(Email)) = LOWER(TRIM(emailOrganizacije))
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija sa email adresom "%" već postoji',emailOrganizacije;
    END IF;
	IF EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE LOWER(TRIM(Broj_telefona)) = LOWER(TRIM(brojTelefonaOrganizacije))
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija sa tim brojem telefona već postoji';
    END IF;
    SELECT Id INTO idMenadzera
    FROM Korisnik
    WHERE LOWER(TRIM(Ime)) = LOWER(TRIM(imeMenadzera)) AND LOWER(TRIM(Prezime)) = LOWER(TRIM(prezimeMenadzera))
      AND LOWER(TRIM(Email)) = LOWER(TRIM(emailMenadzera)) AND Aktivan = TRUE;
    IF idMenadzera IS NULL THEN
        RAISE EXCEPTION 'Menadžer sa unetim imenom, prezimenom i email adresom ne postoji ili nije aktivan';
    END IF;
    INSERT INTO Turisticka_organizacija (Naziv,Opis,Email,Broj_telefona,idMenadzera)
    VALUES (TRIM(nazivOrganizacije),TRIM(opisOrganizacije),TRIM(emailOrganizacije),TRIM(brojTelefonaOrganizacije),idMenadzera);
END;
$$;

---izmeni_turisticku_organizaciju---
CREATE PROCEDURE izmeni_turisticku_organizaciju(
    idOrganizacije INT,
    nazivOrganizacije VARCHAR(50),
    emailOrganizacije VARCHAR(50),
    brojTelefonaOrganizacije VARCHAR(15)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE Id = idOrganizacije
    )
    THEN
        RAISE EXCEPTION 'Tražena turistička organizacija ne postoji';
    END IF;
    IF nazivOrganizacije IS NULL OR TRIM(nazivOrganizacije) = '' THEN
        RAISE EXCEPTION 'Naziv turističke organizacije ne može biti prazan';
    END IF;
    IF emailOrganizacije IS NULL OR TRIM(emailOrganizacije) = '' THEN
        RAISE EXCEPTION 'Email turističke organizacije ne može biti prazan';
    END IF;
    IF brojTelefonaOrganizacije IS NULL OR TRIM(brojTelefonaOrganizacije) = '' THEN
        RAISE EXCEPTION 'Broj telefona turističke organizacije ne može biti prazan';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivOrganizacije)) AND Id <> idOrganizacije AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija sa nazivom "%" već postoji',nazivOrganizacije;
    END IF;
	IF EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE TRIM(Broj_telefona) = TRIM(brojTelefonaOrganizacije) AND Id <> idOrganizacije AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija sa tim brojem telefona već postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE LOWER(TRIM(Email)) = LOWER(TRIM(emailOrganizacije)) AND Id <> idOrganizacije
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija sa email adresom "%" već postoji', emailOrganizacije;
    END IF;
    UPDATE Turisticka_organizacija
    SET Naziv = TRIM(nazivOrganizacije),
        Email = TRIM(emailOrganizacije),
        Broj_telefona = TRIM(brojTelefonaOrganizacije),
        Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idOrganizacije;
END;
$$;
---promeni_menadzera_organizacije---
CREATE PROCEDURE promeni_menadzera_organizacije(
    idOrganizacije INT,
    imeMenadzera VARCHAR(30),
    prezimeMenadzera VARCHAR(50),
    emailMenadzera VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    idMenadzera INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE Id = idOrganizacije
    )
    THEN
        RAISE EXCEPTION 'Tražena turistička organizacija ne postoji';
    END IF;
    IF imeMenadzera IS NULL OR TRIM(imeMenadzera) = '' THEN
        RAISE EXCEPTION 'Ime menadžera ne može biti prazno';
    END IF;
    IF prezimeMenadzera IS NULL OR TRIM(prezimeMenadzera) = '' THEN
        RAISE EXCEPTION 'Prezime menadžera ne može biti prazno';
    END IF;
    IF emailMenadzera IS NULL OR TRIM(emailMenadzera) = '' THEN
        RAISE EXCEPTION 'Email menadžera ne može biti prazan';
    END IF;
    SELECT Id INTO idMenadzera
    FROM Korisnik
    WHERE LOWER(TRIM(Ime)) = LOWER(TRIM(imeMenadzera))
      AND LOWER(TRIM(Prezime)) = LOWER(TRIM(prezimeMenadzera))
      AND LOWER(TRIM(Email)) = LOWER(TRIM(emailMenadzera))
      AND Aktivan = TRUE;
    IF idMenadzera IS NULL THEN
        RAISE EXCEPTION 'Menadžer sa unetim imenom, prezimenom i email adresom ne postoji ili nije aktivan';
    END IF;
    UPDATE Turisticka_organizacija
    SET idMenadzera = idMenadzera,Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idOrganizacije;
END;
$$;
---deaktiviraj_turisticku_organizaciju---
CREATE PROCEDURE deaktiviraj_turisticku_organizaciju(
    idOrganizacije INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE Id = idOrganizacije
    )
    THEN
        RAISE EXCEPTION 'Tražena turistička organizacija ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE Id = idOrganizacije AND Aktivan = FALSE
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija je već deaktivirana';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE idOrganizacije = idOrganizacije AND Aktivan = TRUE AND Datum_kraja > CURRENT_TIMESTAMP
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija ne može biti deaktivirana jer ima aktivnu turističku turu koja još nije završena';
    END IF;
    UPDATE Turisticka_organizacija
    SET Aktivan = FALSE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idOrganizacije;
END;
$$;
---aktiviraj_turisticku_organizaciju---
CREATE PROCEDURE aktiviraj_turisticku_organizaciju(
    idOrganizacije INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE Id = idOrganizacije
    )
    THEN
        RAISE EXCEPTION 'Tražena turistička organizacija ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE Id = idOrganizacije AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Turistička organizacija je već aktivna';
    END IF;
    UPDATE Turisticka_organizacija
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idOrganizacije;
END;
$$;
---TABELA TURISTICKA TURA---
---dodaj_turisticku_turu---
CREATE PROCEDURE dodaj_turisticku_turu(
    datumPocetkaTure TIMESTAMP,
    datumKrajaTure TIMESTAMP,
    cenaTure NUMERIC(10,2),
    nazivPrevozaTure VARCHAR(50),
    nazivSmestajaTure VARCHAR(50),
    nazivMestaSmestaja VARCHAR(50),
    opisTure VARCHAR(255),
    nazivOrganizacijeTure VARCHAR(50),
    nazivDestinacijeTure VARCHAR(50),
    nazivMestaDestinacije VARCHAR(50),
    brojMestaTure INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    idPrevozaTure INT;
    idSmestajaTure INT;
    idOrganizacijeTure INT;
    idDestinacijeTure INT;
BEGIN
    IF datumPocetkaTure IS NULL THEN
        RAISE EXCEPTION 'Datum početka ture ne može biti prazan';
    END IF;
    IF datumKrajaTure IS NULL THEN
        RAISE EXCEPTION 'Datum kraja ture ne može biti prazan';
    END IF;
    IF datumKrajaTure < datumPocetkaTure THEN
        RAISE EXCEPTION 'Datum kraja ture mora biti posle datuma početka';
    END IF;
    IF cenaTure IS NULL OR cenaTure <= 0 THEN
        RAISE EXCEPTION 'Cena ture mora biti veća od nule';
    END IF;
    IF brojMestaTure IS NULL OR brojMestaTure <= 0 THEN
        RAISE EXCEPTION 'Broj mesta mora biti veći od nule';
    END IF;
    IF nazivPrevozaTure IS NULL OR TRIM(nazivPrevozaTure) = '' THEN
        RAISE EXCEPTION 'Naziv prevoza ne može biti prazan';
    END IF;
    IF nazivOrganizacijeTure IS NULL OR TRIM(nazivOrganizacijeTure) = '' THEN
        RAISE EXCEPTION 'Naziv turističke organizacije ne može biti prazan';
    END IF;
    IF nazivDestinacijeTure IS NULL OR TRIM(nazivDestinacijeTure) = '' THEN
        RAISE EXCEPTION 'Naziv destinacije ne može biti prazan';
    END IF;
    IF nazivMestaDestinacije IS NULL OR TRIM(nazivMestaDestinacije) = '' THEN
        RAISE EXCEPTION 'Mesto destinacije ne može biti prazno';
    END IF;
    SELECT Id INTO idPrevozaTure
    FROM Prevoz
    WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivPrevozaTure)) AND Aktivan = TRUE;
    IF idPrevozaTure IS NULL THEN
        RAISE EXCEPTION 'Prevoz sa nazivom "%" ne postoji ili nije aktivan',nazivPrevozaTure;
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE idPrevoza = idPrevozaTure AND Aktivan = TRUE
          AND Datum_pocetka < datumKrajaTure
          AND Datum_kraja > datumPocetkaTure
    )
    THEN
        RAISE EXCEPTION 'Prevoz "%" nije slobodan u izabranom periodu', nazivPrevozaTure;
    END IF;
    IF DATE(datumKrajaTure) > DATE(datumPocetkaTure) THEN
	    IF nazivSmestajaTure IS NULL OR TRIM(nazivSmestajaTure) = '' THEN
	        RAISE EXCEPTION 'Smeštaj mora biti naveden za turu koja traje više od jednog dana';
	    END IF;
        IF nazivMestaSmestaja IS NULL OR TRIM(nazivMestaSmestaja) = '' THEN
            RAISE EXCEPTION 'Mesto smeštaja mora biti navedeno';
        END IF;
        SELECT s.Id INTO idSmestajaTure
        FROM Smestaj s JOIN Mesto m ON m.Id = s.Id_mesta
        WHERE LOWER(TRIM(s.Naziv)) = LOWER(TRIM(nazivSmestajaTure)) AND LOWER(TRIM(m.Naziv)) = LOWER(TRIM(nazivMestaSmestaja))
          AND s.Aktivan = TRUE AND m.Aktivan = TRUE;
        IF idSmestajaTure IS NULL THEN
            RAISE EXCEPTION 'Smeštaj "%" u mestu "%" ne postoji ili nije aktivan', nazivSmestajaTure, nazivMestaSmestaja;
        END IF;
        IF EXISTS (
            SELECT 1
            FROM Turisticka_tura
            WHERE idSmestaja = idSmestajaTure AND Aktivan = TRUE AND Datum_pocetka < datumKrajaTure AND Datum_kraja > datumPocetkaTure
        )
        THEN
            RAISE EXCEPTION 'Smeštaj "%" u mestu "%" nije slobodan u izabranom periodu', nazivSmestajaTure, nazivMestaSmestaja;
        END IF;
    ELSE
        idSmestajaTure := NULL;
    END IF;
    SELECT Id INTO idOrganizacijeTure
    FROM Turisticka_organizacija
    WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivOrganizacijeTure)) AND Aktivan = TRUE;
    IF idOrganizacijeTure IS NULL THEN
        RAISE EXCEPTION 'Turistička organizacija "%" ne postoji ili nije aktivna', nazivOrganizacijeTure;
    END IF;
    SELECT d.Id INTO idDestinacijeTure
    FROM Destinacija d JOIN Mesto m ON m.Id = d.Id_mesta
    WHERE LOWER(TRIM(d.Naziv)) = LOWER(TRIM(nazivDestinacijeTure))
      AND LOWER(TRIM(m.Naziv)) = LOWER(TRIM(nazivMestaDestinacije))
      AND d.Aktivan = TRUE AND m.Aktivan = TRUE;
    IF idDestinacijeTure IS NULL THEN
        RAISE EXCEPTION 'Destinacija "%" u mestu "%" ne postoji ili nije aktivna', nazivDestinacijeTure, nazivMestaDestinacije;
    END IF;
    INSERT INTO Turisticka_tura ( Datum_pocetka,Datum_kraja,Cena,idPrevoza,idSmestaja,
        Opis,idOrganizacije,idDestinacije,BrojMesta)
    VALUES (datumPocetkaTure,datumKrajaTure,cenaTure,idPrevozaTure,idSmestajaTure,
        TRIM(opisTure),idOrganizacijeTure,idDestinacijeTure,brojMestaTure);
END;
$$;

---izmeni_turisticku_turu---
CREATE PROCEDURE izmeni_turisticku_turu(
    idTure INT,
    nazivPrevozaTure VARCHAR(50),
    nazivSmestajaTure VARCHAR(50),
    nazivMestaSmestaja VARCHAR(50),
    opisTure VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    idPrevozaTure INT;
    idSmestajaTure INT;
    datumPocetkaTure TIMESTAMP;
    datumKrajaTure TIMESTAMP;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE Id = idTure
    )
    THEN
        RAISE EXCEPTION 'Tražena turistička tura ne postoji';
    END IF;
    SELECT Datum_pocetka, Datum_kraja
    INTO datumPocetkaTure, datumKrajaTure
    FROM Turisticka_tura
    WHERE Id = idTure;
    IF nazivPrevozaTure IS NULL OR TRIM(nazivPrevozaTure) = '' THEN
        RAISE EXCEPTION 'Naziv prevoza ne može biti prazan';
    END IF;
    SELECT Id INTO idPrevozaTure
    FROM Prevoz
    WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivPrevozaTure)) AND Aktivan = TRUE;
    IF idPrevozaTure IS NULL THEN
        RAISE EXCEPTION 'Prevoz "%" ne postoji ili nije aktivan',nazivPrevozaTure;
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE idPrevoza = idPrevozaTure AND Id <> idTure AND Aktivan = TRUE AND Datum_pocetka < datumKrajaTure AND Datum_kraja > datumPocetkaTure
    )
    THEN
        RAISE EXCEPTION
            'Prevoz "%" nije slobodan u periodu turističke ture',nazivPrevozaTure;
    END IF;
    IF DATE(datumKrajaTure) > DATE(datumPocetkaTure) THEN
        IF nazivSmestajaTure IS NULL OR TRIM(nazivSmestajaTure) = '' THEN
            RAISE EXCEPTION'Smeštaj mora biti naveden za turu koja traje više od jednog dana';
        END IF;
        IF nazivMestaSmestaja IS NULL OR TRIM(nazivMestaSmestaja) = '' THEN
            RAISE EXCEPTION'Mesto smeštaja mora biti navedeno';
        END IF;
        SELECT s.Id INTO idSmestajaTure
        FROM Smestaj s JOIN Mesto m ON m.Id = s.Id_mesta
        WHERE LOWER(TRIM(s.Naziv)) = LOWER(TRIM(nazivSmestajaTure))
          AND LOWER(TRIM(m.Naziv)) = LOWER(TRIM(nazivMestaSmestaja)) AND s.Aktivan = TRUE AND m.Aktivan = TRUE;
        IF idSmestajaTure IS NULL THEN
            RAISE EXCEPTION 'Smeštaj "%" u mestu "%" ne postoji ili nije aktivan', nazivSmestajaTure,nazivMestaSmestaja;
        END IF;
        IF EXISTS (
            SELECT 1
            FROM Turisticka_tura
            WHERE idSmestaja = idSmestajaTure AND Id <> idTure AND Aktivan = TRUE AND Datum_pocetka < datumKrajaTure AND Datum_kraja > datumPocetkaTure
        )
        THEN
            RAISE EXCEPTION 'Smeštaj "%" u mestu "%" nije slobodan u periodu turističke ture',nazivSmestajaTure,nazivMestaSmestaja;
        END IF;
    ELSE
        idSmestajaTure := NULL;
    END IF;
    UPDATE Turisticka_tura
    SET idPrevoza = idPrevozaTure,
        idSmestaja = idSmestajaTure,
        Opis = TRIM(opisTure),
        Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idTure;
END;
$$;
---promeni_kapacitet_ture---
CREATE PROCEDURE promeni_kapacitet_ture(
    idTure INT,
    noviBrojMesta INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    brojPutnika INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE Id = idTure
    )
    THEN
        RAISE EXCEPTION 'Tražena turistička tura ne postoji';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE Id = idTure AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Turistička tura nije aktivna';
    END IF;
    IF noviBrojMesta IS NULL OR noviBrojMesta <= 0 THEN
        RAISE EXCEPTION 'Broj mesta mora biti veći od nule';
    END IF;
    brojPutnika := broj_zauzetih_mesta(idTure);
	IF noviBrojMesta < brojPutnika THEN
    RAISE EXCEPTION 'Novi kapacitet ne može biti manji od broja putnika sa aktivnim rezervacijama';
	END IF;
    UPDATE Turisticka_tura
    SET BrojMesta = noviBrojMesta,Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idTure;
END;
$$;
---deaktiviraj_turu---
CREATE PROCEDURE deaktiviraj_turu(
    idTure INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE Id = idTure
    )
    THEN
        RAISE EXCEPTION 'Tražena turistička tura ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE Id = idTure AND Aktivan = FALSE
    )
    THEN
        RAISE EXCEPTION 'Turistička tura je već deaktivirana';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Rezervacija
        WHERE idTure = idTure AND Aktivan = TRUE AND Status_rezervacije = 'Aktivna'
    )
    THEN
        RAISE EXCEPTION 'Turistička tura ne može biti deaktivirana jer postoje aktivne rezervacije';
    END IF;
    UPDATE Turisticka_tura
    SET Aktivan = FALSE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idTure;
END;
$$;
---aktiviraj_turu---
CREATE PROCEDURE aktiviraj_turu(
    idTure INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE Id = idTure
    )
    THEN
        RAISE EXCEPTION 'Tražena turistička tura ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE Id = idTure AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Turistička tura je već aktivna';
    END IF;
    UPDATE Turisticka_tura
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idTure;
END;
$$;
---TABELA OCENA---
CREATE PROCEDURE dodaj_ocenu(
    idKorisnika INT,
    idRezervacije INT,
    ocenaOrganizacije INT,
    komentarOcene VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF idKorisnika IS NULL THEN
        RAISE EXCEPTION 'Korisnik mora biti naveden';
    END IF;
    IF idRezervacije IS NULL THEN
        RAISE EXCEPTION 'Rezervacija mora biti navedena';
    END IF;
    IF ocenaOrganizacije IS NULL OR ocenaOrganizacije < 1 OR ocenaOrganizacije > 5 THEN
        RAISE EXCEPTION 'Ocena mora biti između 1 i 5';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id = idKorisnika AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Traženi korisnik ne postoji ili nije aktivan';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Rezervacija WHERE Id = idRezervacije
    )
    THEN
        RAISE EXCEPTION 'Tražena rezervacija ne postoji';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Rezervacija
        WHERE Id = idRezervacije AND Id_nosioca_rezervacije = idKorisnika
    )
    THEN
        RAISE EXCEPTION 'Korisnik nije nosilac navedene rezervacije';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Rezervacija
        WHERE Id = idRezervacije
          AND Status_rezervacije = 'Realizovana'
		  AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Ocena se može ostaviti samo za realizovanu rezervaciju';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Ocena
        WHERE idKorisnika = idKorisnika AND idRezervacije = idRezervacije
    )
    THEN
        RAISE EXCEPTION 'Korisnik je već ocenio ovu rezervaciju';
    END IF;
    INSERT INTO Ocena (
        idKorisnika,
        idRezervacije,
        Ocena,
        Komentar
    )
    VALUES (
        idKorisnika,
        idRezervacije,
        ocenaOrganizacije,
        TRIM(komentarOcene)
    );
END;
$$;
