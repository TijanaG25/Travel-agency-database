---TABELA ULOGA---
---dodaj_ulogu---
CREATE PROCEDURE dodaj_ulogu(
    nazivUloge VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF nazivUloge IS NULL OR TRIM(nazivUloge) = '' THEN 
		RAISE EXCEPTION 'Naziv uloge ne može biti prazan';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Uloga
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivUloge))
    ) 
	THEN
        RAISE EXCEPTION 'Uloga sa nazivom "%" već postoji', nazivUloge;
    END IF;
    INSERT INTO Uloga (Naziv)
    VALUES (TRIM(nazivUloge));
END;
$$;

---izmeni_ulogu---
CREATE PROCEDURE izmeni_ulogu(
    idUloge INT,
    nazivUloge VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF nazivUloge IS NULL OR TRIM(nazivUloge) = '' THEN
        RAISE EXCEPTION 'Naziv uloge ne može biti prazan';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Uloga
        WHERE Id = idUloge
    )
    THEN
        RAISE EXCEPTION 'Trazena uloga ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Uloga
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivUloge)) AND Id <> idUloge
    )
    THEN
        RAISE EXCEPTION 'Uloga sa nazivom "%" već postoji', nazivUloge;
    END IF;
    UPDATE Uloga
    SET Naziv = TRIM(nazivUloge), Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idUloge;
END;
$$;

---deaktiviraj_ulogu---
CREATE PROCEDURE deaktiviraj_ulogu(
    idUloge INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Uloga
        WHERE Id = idUloge
    )
    THEN
        RAISE EXCEPTION 'Trazena uloga ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Uloga
        WHERE Id = idUloge AND Aktivan = FALSE
    )
    THEN
        RAISE EXCEPTION 'Uloga je već deaktivirana';
    END IF;
	IF EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id_uloge = idUloge AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Uloga ne moze biti deaktivirana jer postoji aktivan korisnik sa tom ulogom.';
    END IF;
    UPDATE Uloga
    SET Aktivan = FALSE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idUloge;
END;
$$;

---aktiviraj_ulogu---
CREATE PROCEDURE aktiviraj_ulogu(
    idUloge INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Uloga
        WHERE Id = idUloge
    )
    THEN
        RAISE EXCEPTION 'Tražena uloga ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Uloga
        WHERE Id = idUloge AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Uloga je već aktivna';
    END IF;
    UPDATE Uloga
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idUloge;
END;
$$;

---TABELA MESTO---
---dodaj_mesto---
CREATE PROCEDURE dodaj_mesto(
    nazivMesta VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF nazivMesta IS NULL OR TRIM(nazivMesta) = '' THEN
        RAISE EXCEPTION 'Naziv mesta ne može biti prazan';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Mesto
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivMesta))
    )
    THEN
        RAISE EXCEPTION 'Mesto sa nazivom "%" već postoji', nazivMesta;
    END IF;
    INSERT INTO Mesto (Naziv)
    VALUES (TRIM(nazivMesta));
END;
$$;


---izmeni_mesto---
CREATE PROCEDURE izmeni_mesto(
    idMesta INT,
    nazivMesta VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF nazivMesta IS NULL OR TRIM(nazivMesta) = '' THEN
        RAISE EXCEPTION 'Naziv mesta ne može biti prazan';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM Mesto
        WHERE Id = idMesta
    )
    THEN
        RAISE EXCEPTION 'Traženo mesto ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Mesto
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivMesta)) AND Id <> idMesta
    )
    THEN
        RAISE EXCEPTION 'Mesto sa nazivom "%" već postoji', nazivMesta;
    END IF;
    UPDATE Mesto
    SET Naziv = TRIM(nazivMesta), Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idMesta;
END;
$$;


---deaktiviraj_mesto---
CREATE PROCEDURE deaktiviraj_mesto(
    idMesta INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Mesto
        WHERE Id = idMesta
    )
    THEN
        RAISE EXCEPTION 'Traženo mesto ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Mesto
        WHERE Id = idMesta AND Aktivan = FALSE
    )
    THEN
        RAISE EXCEPTION 'Mesto je već deaktivirano';
    END IF;
	IF EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id_mestaStanovanja = idMesta AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Postoji aktivan korisnik koji zivi u tom mestu i mesto ne moze biti deaktivirano.';
    END IF;
	IF EXISTS (
        SELECT 1
        FROM Putnik
        WHERE Id_mestaStanovanja = idMesta AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Postoji aktivan putnik koji zivi u tom mestu i mesto ne moze biti deaktivirano.';
    END IF;
	IF EXISTS (
        SELECT 1
        FROM Smestaj
        WHERE Id_mesta = idMesta AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Postoji aktivan smestaj koji se nalazi u tom mestu i mesto ne moze biti deaktivirano.';
    END IF;
	IF EXISTS (
        SELECT 1
        FROM Destinacija
        WHERE Id_mesta = idMesta AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Postoji aktivna destinacija koja se nalazi u tom mestu i mesto ne moze biti deaktivirano.';
    END IF;
    UPDATE Mesto
    SET Aktivan = FALSE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idMesta;
END;
$$;

---aktiviraj_mesto---
CREATE PROCEDURE aktiviraj_mesto(
    idMesta INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Mesto
        WHERE Id = idMesta
    )
    THEN
        RAISE EXCEPTION 'Traženo mesto ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Mesto
        WHERE Id = idMesta AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Mesto je već aktivno';
    END IF;
    UPDATE Mesto
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idMesta;
END;
$$;
---TABELA KORISNIK---
---registruj_korisnika---
CREATE OR REPLACE PROCEDURE registruj_korisnika(
    imeKorisnika VARCHAR(50),
    prezimeKorisnika VARCHAR(50),
    emailKorisnika VARCHAR(100),
    lozinkaKorisnika VARCHAR(255),
    BrojTelefona VARCHAR(15),
    jmbgKorisnika CHAR(13),
    nazivMesta VARCHAR(50),
    AdresaStanovanja VARCHAR(50),
    nazivUloge VARCHAR(50) DEFAULT 'Korisnik'
)
LANGUAGE plpgsql
AS $$
DECLARE
    idUloge INT;
    idMestaStanovanja INT;
BEGIN
    IF imeKorisnika IS NULL OR TRIM(imeKorisnika) = '' THEN
        RAISE EXCEPTION 'Ime korisnika ne može biti prazno';
    END IF;
    IF prezimeKorisnika IS NULL OR TRIM(prezimeKorisnika) = '' THEN
        RAISE EXCEPTION 'Prezime korisnika ne može biti prazno';
    END IF;
    IF emailKorisnika IS NULL OR TRIM(emailKorisnika) = '' THEN
        RAISE EXCEPTION 'Email korisnika ne može biti prazan';
    END IF;
    IF lozinkaKorisnika IS NULL OR TRIM(lozinkaKorisnika) = '' THEN
        RAISE EXCEPTION 'Lozinka korisnika ne može biti prazna';
    END IF;
    IF BrojTelefona IS NULL OR TRIM(BrojTelefona) = '' THEN
        RAISE EXCEPTION 'Broj telefona korisnika ne može biti prazan';
    END IF;
    IF jmbgKorisnika IS NULL OR TRIM(jmbgKorisnika) = '' THEN
        RAISE EXCEPTION 'JMBG korisnika ne može biti prazan';
    END IF;
    IF nazivMesta IS NULL OR TRIM(nazivMesta) = '' THEN
        RAISE EXCEPTION 'Mesto stanovanja korisnika ne može biti prazno';
    END IF;
    IF AdresaStanovanja IS NULL OR TRIM(AdresaStanovanja) = '' THEN
        RAISE EXCEPTION 'Adresa stanovanja korisnika ne može biti prazna';
    END IF;
    IF nazivUloge IS NULL OR TRIM(nazivUloge) = '' THEN nazivUloge := 'Korisnik';
    END IF;
    IF postoji_email(emailKorisnika) THEN
        RAISE EXCEPTION 'Korisnik sa email adresom "%" već postoji',emailKorisnika;
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Jmbg = jmbgKorisnika
    ) THEN
        RAISE EXCEPTION 'Korisnik sa JMBG-om "%" već postoji',jmbgKorisnika;
    END IF;
    SELECT Id INTO idUloge
    FROM Uloga
    WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivUloge)) AND Aktivan = TRUE;
    IF idUloge IS NULL THEN
        RAISE EXCEPTION 'Uloga "%" ne postoji ili nije aktivna',nazivUloge;
    END IF;
    SELECT Id INTO idMestaStanovanja
    FROM Mesto
    WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivMesta)) AND Aktivan = TRUE;
    IF idMestaStanovanja IS NULL THEN
        CALL dodaj_mesto(TRIM(nazivMesta));
        SELECT Id INTO idMestaStanovanja
        FROM Mesto
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivMesta)) AND Aktivan = TRUE;
    END IF;
    INSERT INTO Korisnik (Ime,Prezime,Email,Lozinka,Broj_telefona,Jmbg,Id_uloge,Id_mestaStanovanja,Adresa_stanovanja)
    VALUES (TRIM(imeKorisnika),TRIM(prezimeKorisnika),TRIM(emailKorisnika),crypt(lozinkaKorisnika, gen_salt('bf')),
        TRIM(BrojTelefona),TRIM(jmbgKorisnika),idUloge,idMestaStanovanja,TRIM(AdresaStanovanja));
END;
$$;
---izmeni_korisnika---
CREATE PROCEDURE izmeni_korisnika(
    idKorisnika INT,
    imeKorisnika VARCHAR(50),
    prezimeKorisnika VARCHAR(50),
    emailKorisnika VARCHAR(100),
    lozinkaKorisnika VARCHAR(255),
    brojTelefona VARCHAR(15),
    nazivMesta VARCHAR(50),
    adresaStanovanja VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    idMestaStanovanja INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id = idKorisnika
    )
    THEN
        RAISE EXCEPTION 'Traženi korisnik ne postoji';
    END IF;
    IF imeKorisnika IS NULL OR TRIM(imeKorisnika) = '' THEN
        RAISE EXCEPTION 'Ime korisnika ne može biti prazno';
    END IF;
    IF prezimeKorisnika IS NULL OR TRIM(prezimeKorisnika) = '' THEN
        RAISE EXCEPTION 'Prezime korisnika ne može biti prazno';
    END IF;
    IF emailKorisnika IS NULL OR TRIM(emailKorisnika) = '' THEN
        RAISE EXCEPTION 'Email korisnika ne može biti prazan';
    END IF;
    IF lozinkaKorisnika IS NULL OR TRIM(lozinkaKorisnika) = '' THEN
        RAISE EXCEPTION 'Lozinka korisnika ne može biti prazna';
    END IF;
    IF brojTelefona IS NULL OR TRIM(brojTelefona) = '' THEN
        RAISE EXCEPTION 'Broj telefona korisnika ne može biti prazan';
    END IF;
    IF nazivMesta IS NULL OR TRIM(nazivMesta) = '' THEN
        RAISE EXCEPTION 'Mesto stanovanja korisnika ne može biti prazno';
    END IF;
    IF adresaStanovanja IS NULL OR TRIM(adresaStanovanja) = '' THEN
        RAISE EXCEPTION 'Adresa stanovanja korisnika ne može biti prazna';
    END IF;
    IF postoji_email(emailKorisnika) THEN
        RAISE EXCEPTION 'Korisnik sa email adresom "%" već postoji',emailKorisnika;
    END IF;
    SELECT Id
    INTO idMestaStanovanja
    FROM Mesto
    WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivMesta)) AND Aktivan = TRUE;
    IF idMestaStanovanja IS NULL THEN
        CALL dodaj_mesto(TRIM(nazivMesta));
        SELECT Id INTO idMestaStanovanja
        FROM Mesto
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivMesta)) AND Aktivan = TRUE;
    END IF;
    UPDATE Korisnik
    SET Ime = TRIM(imeKorisnika), Prezime = TRIM(prezimeKorisnika), Email = TRIM(emailKorisnika),
        Lozinka = crypt(lozinkaKorisnika, gen_salt('bf')),Broj_telefona = TRIM(brojTelefona),Id_mestaStanovanja = idMestaStanovanja,Adresa_stanovanja = TRIM(adresaStanovanja),Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idKorisnika;
END;
$$;
---promeni_ulogu_korisnika---
CREATE PROCEDURE promeni_ulogu_korisnika(
    idKorisnika INT,
    nazivUloge VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    idUloge INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id = idKorisnika
    )
    THEN
        RAISE EXCEPTION 'Traženi korisnik ne postoji';
    END IF;
    IF nazivUloge IS NULL OR TRIM(nazivUloge) = '' THEN
        RAISE EXCEPTION 'Naziv uloge ne može biti prazan';
    END IF;
    SELECT Id INTO idUloge
    FROM Uloga
    WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivUloge)) AND Aktivan = TRUE;
    IF idUloge IS NULL THEN
        RAISE EXCEPTION 'Uloga "%" ne postoji ili nije aktivna',nazivUloge;
    END IF;
    UPDATE Korisnik
    SET Id_uloge = idUloge,Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idKorisnika;
END;
$$;
---deaktiviraj_korisnika---
CREATE PROCEDURE deaktiviraj_korisnika(
    idKorisnika INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id = idKorisnika
    )
    THEN
        RAISE EXCEPTION 'Traženi korisnik ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id = idKorisnika AND Aktivan = FALSE
    )
    THEN
        RAISE EXCEPTION 'Korisnik je već deaktiviran';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Organizacija
        WHERE Id_menadzera = idKorisnika AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Korisnik ne može biti deaktiviran jer je menadžer aktivne organizacije';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Rezervacija
        WHERE Id_nosioca_rezervacije = idKorisnika AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Korisnik ne može biti deaktiviran jer ima aktivnu rezervaciju';
    END IF;
    UPDATE Korisnik
    SET Aktivan = FALSE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idKorisnika;
END;
$$;

---aktiviraj_korisnika---
CREATE PROCEDURE aktiviraj_korisnika(
    idKorisnika INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id = idKorisnika
    )
    THEN
        RAISE EXCEPTION 'Traženi korisnik ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Id = idKorisnika AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Korisnik je već aktivan';
    END IF;
    UPDATE Korisnik
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idKorisnika;
END;
$$;

---TABELA SMESTAJ---
---dodaj_smestaj---
CREATE PROCEDURE dodaj_smestaj(
    nazivSmestaja VARCHAR(50),
    vrstaSmestaja VARCHAR(50),
    nazivMesta VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    idMesta INT;
BEGIN
    IF nazivSmestaja IS NULL OR TRIM(nazivSmestaja) = '' THEN
        RAISE EXCEPTION 'Naziv smeštaja ne može biti prazan';
    END IF;
    IF vrstaSmestaja IS NULL OR TRIM(vrstaSmestaja) = '' THEN
        RAISE EXCEPTION 'Vrsta smeštaja ne može biti prazna';
    END IF;
    IF nazivMesta IS NULL OR TRIM(nazivMesta) = '' THEN
        RAISE EXCEPTION 'Mesto smeštaja ne može biti prazno';
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
        FROM Smestaj
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivSmestaja)) AND
		Id_mesta=idMesta AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Smeštaj već postoji';
    END IF;
    INSERT INTO Smestaj (Naziv,Vrsta,Id_mesta)
    VALUES (TRIM(nazivSmestaja),TRIM(vrstaSmestaja),idMesta);
END;
$$;

---izmeni_smestaj---
CREATE PROCEDURE izmeni_smestaj(
    idSmestaja INT,
    nazivSmestaja VARCHAR(50),
    vrstaSmestaja VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Smestaj
        WHERE Id = idSmestaja
    )
    THEN
        RAISE EXCEPTION 'Traženi smeštaj ne postoji';
    END IF;
    IF nazivSmestaja IS NULL OR TRIM(nazivSmestaja) = '' THEN
        RAISE EXCEPTION 'Naziv smeštaja ne može biti prazan';
    END IF;
    IF vrstaSmestaja IS NULL OR TRIM(vrstaSmestaja) = '' THEN
        RAISE EXCEPTION 'Vrsta smeštaja ne može biti prazna';
    END IF;
    UPDATE Smestaj
    SET Naziv = TRIM(nazivSmestaja),Vrsta = TRIM(vrstaSmestaja),Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idSmestaja;
END;
$$;
---deaktiviraj_smestaj---
CREATE PROCEDURE deaktiviraj_smestaj(
    idSmestaja INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Smestaj
        WHERE Id = idSmestaja
    )
    THEN
        RAISE EXCEPTION 'Traženi smeštaj ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Smestaj
        WHERE Id = idSmestaja AND Aktivan = FALSE
    )
    THEN
        RAISE EXCEPTION 'Smeštaj je već deaktiviran';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Turisticka_tura
        WHERE idSmestaja = idSmestaja AND Aktivan = TRUE AND Datum_pocetka > CURRENT_TIMESTAMP
    )
    THEN
        RAISE EXCEPTION 'Smeštaj ne može biti deaktiviran jer postoji aktivna turistička tura koja ga koristi';
    END IF;
    UPDATE Smestaj
    SET Aktivan = FALSE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idSmestaja;
END;
$$;

---aktiviraj_smestaj---
CREATE PROCEDURE aktiviraj_smestaj(
    idSmestaja INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Smestaj
        WHERE Id = idSmestaja
    )
    THEN
        RAISE EXCEPTION 'Traženi smeštaj ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Smestaj
        WHERE Id = idSmestaja AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Smeštaj je već aktivan';
    END IF;
    UPDATE Smestaj
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idSmestaja;
END;
$$;


---TABELA PREVOZ---
---dodaj_prevoz---
CREATE PROCEDURE dodaj_prevoz(
    nazivPrevoza VARCHAR(50),
    vrstaPrevoza VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF nazivPrevoza IS NULL OR TRIM(nazivPrevoza) = '' THEN
        RAISE EXCEPTION 'Naziv prevoza ne može biti prazan';
    END IF;
    IF vrstaPrevoza IS NULL OR TRIM(vrstaPrevoza) = '' THEN
        RAISE EXCEPTION 'Vrsta prevoza ne može biti prazna';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Prevoz
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivPrevoza))  AND
		LOWER(TRIM(Vrsta)) = LOWER(TRIM(vrstaPrevoza)) AND Aktivan = TRUE)
    THEN
        RAISE EXCEPTION 'Prevoz već postoji';
    END IF;
    INSERT INTO Prevoz (Naziv,Vrsta)
    VALUES (TRIM(nazivPrevoza),TRIM(vrstaPrevoza));
END;
$$;


---izmeni_prevoz---
CREATE PROCEDURE izmeni_prevoz(
    idPrevoza INT,
    nazivPrevoza VARCHAR(50),
    vrstaPrevoza VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Prevoz
        WHERE Id = idPrevoza
    )
    THEN
        RAISE EXCEPTION 'Traženi prevoz ne postoji';
    END IF;
    IF nazivPrevoza IS NULL OR TRIM(nazivPrevoza) = '' THEN
        RAISE EXCEPTION 'Naziv prevoza ne može biti prazan';
    END IF;
    IF vrstaPrevoza IS NULL OR TRIM(vrstaPrevoza) = '' THEN
        RAISE EXCEPTION 'Vrsta prevoza ne može biti prazna';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Prevoz
        WHERE LOWER(TRIM(Naziv)) = LOWER(TRIM(nazivPrevoza)) AND LOWER(TRIM(Vrsta)) = LOWER(TRIM(vrstaPrevoza))
          AND Id <> idPrevoza AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Prevoz već postoji';
    END IF;
    UPDATE Prevoz
    SET Naziv = TRIM(nazivPrevoza),Vrsta = TRIM(vrstaPrevoza),Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idPrevoza;
END;
$$;

---deaktiviraj_prevoz---
CREATE PROCEDURE deaktiviraj_prevoz(
    idPrevoza INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Prevoz
        WHERE Id = idPrevoza
    )
    THEN
        RAISE EXCEPTION 'Traženi prevoz ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Prevoz
        WHERE Id = idPrevoza AND Aktivan = FALSE
    )
    THEN
        RAISE EXCEPTION 'Prevoz je već deaktiviran';
    END IF;
    IF EXISTS (
    SELECT 1
    FROM Turisticka_tura
    WHERE idPrevoza = idPrevoza AND Aktivan = TRUE AND Datum_pocetka > CURRENT_TIMESTAMP)
	THEN
    	RAISE EXCEPTION 'Prevoz ne može biti deaktiviran jer postoji aktivna buduća turistička tura koja ga koristi';
	END IF;
    UPDATE Prevoz
    SET Aktivan = FALSE,Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idPrevoza;
END;
$$;
---aktiviraj_prevoz---
CREATE PROCEDURE aktiviraj_prevoz(
    idPrevoza INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Prevoz
        WHERE Id = idPrevoza
    )
    THEN
        RAISE EXCEPTION 'Traženi prevoz ne postoji';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Prevoz
        WHERE Id = idPrevoza AND Aktivan = TRUE
    )
    THEN
        RAISE EXCEPTION 'Prevoz je već aktivan';
    END IF;
    UPDATE Prevoz
    SET Aktivan = TRUE, Poslednja_izmena = CURRENT_TIMESTAMP
    WHERE Id = idPrevoza;
END;
$$;