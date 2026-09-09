---Provera da li email postoji---
CREATE FUNCTION postoji_email (email VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM Korisnik
        WHERE Email = email
    );
END;
$$;

---Provera da li JMBG postoji---
CREATE FUNCTION postoji_jmbg(jmbg CHAR(13))
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM Putnik
        WHERE Jmbg = jmbg
    );
END;
$$;

---Promena lozinke---
CREATE FUNCTION promeni_lozinku(
    email VARCHAR, nova_lozinka VARCHAR
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Korisnik
    SET Lozinka = nova_lozinka
    WHERE Email = email;
    RETURN FOUND;
END;
$$;

---Provera da li je menadžer već dodeljen organizaciji---
CREATE FUNCTION menadzer_vec_dodeljen(
    id_organizacije INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM Turisticka_organizacija
        WHERE Id=id_organizacije and idMenadzera IS NOT NULL
    );
END;
$$;

---Broj zauzetih mesta na turi---
CREATE FUNCTION broj_zauzetih_mesta(
    id_ture INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE broj_mesta INT =0;
BEGIN
    SELECT COUNT(rp.idPutnika) INTO broj_mesta
    FROM Rezervacija r JOIN Rezervacija_putnik rp ON r.Id = rp.idRezervacije
    WHERE r.idTure = id_ture AND r.Aktivan = TRUE AND r.Status_rezervacije <> 'Otkazana';
    RETURN broj_mesta;
END;
$$;

---Broj slobodnih mesta---
CREATE FUNCTION broj_slobodnih_mesta(
   p_id_ture INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE  ukupan_broj_mesta INT =0;
BEGIN
    SELECT BrojMesta INTO ukupan_broj_mesta
    FROM Turisticka_tura
    WHERE Id = p_id_ture;
    RETURN ukupan_broj_mesta - broj_zauzetih_mesta(p_id_ture);
END;
$$;

---Provera preklapanja termina---
CREATE FUNCTION postoji_preklapanje_termina(
    id_korisnika INT, id_ture INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM Rezervacija r
        JOIN Turisticka_tura tt ON r.idTure = tt.Id
        JOIN Turisticka_tura nova_tura ON nova_tura.Id = id_ture
        WHERE r.Id_nosioca_rezervacije = id_korisnika
          AND r.Aktivan = TRUE AND r.Status_rezervacije <> 'Otkazana'
          AND tt.Datum_pocetka < nova_tura.Datum_kraja AND tt.Datum_kraja > nova_tura.Datum_pocetka
		  AND tt.Aktivan=TRUE AND nova_tura.Aktivan=TRUE
    );
END;
$$;

---Generisanje broja rezervacije---
CREATE SEQUENCE broj_rezervacije_seq
START WITH 1000
INCREMENT BY 1;

CREATE FUNCTION generisi_broj_rezervacije()
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN NEXTVAL('broj_rezervacije_seq');
END;
$$;

---Provera da li putnik već postoji---
CREATE FUNCTION postoji_putnik(
    jmbg CHAR(13)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM Putnik
        WHERE Jmbg = jmbg
    );
END;
$$;

---Provera da li je rezervaciju moguće otkazati---
CREATE OR REPLACE FUNCTION moze_se_otkazati(
    id_rezervacije INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    datum_pocetka_ture TIMESTAMP;
    status_rezervacije status_rezervacije;
    aktivan BOOLEAN;
BEGIN
    SELECT 
        tt.Datum_pocetka,
        r.Status_rezervacije,
        r.Aktivan
    INTO 
        datum_pocetka_ture,
        status_rezervacije,
        aktivan
    FROM Rezervacija r JOIN Turisticka_tura tt ON r.idTure = tt.Id
    WHERE r.Id = id_rezervacije;
    IF datum_pocetka_ture IS NULL THEN
        RETURN FALSE;
    END IF;
    IF aktivan = FALSE THEN
        RETURN FALSE;
    END IF;
    IF status_rezervacije <> 'Realizovana'AND status_rezervacije <> 'Otkazana' AND CURRENT_TIMESTAMP <= datum_pocetka_ture - INTERVAL '7 days'
    THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$;

---Prosečna ocena organizacije---
CREATE FUNCTION prosecna_ocena_organizacije(
    id_organizacije INT
)
RETURNS NUMERIC(3,2)
LANGUAGE plpgsql
AS $$
DECLARE
    prosek NUMERIC(3,2)=0;
BEGIN
    SELECT ROUND(AVG(o.Ocena), 2) INTO prosek
    FROM Turisticka_organizacija tuo JOIN Turisticka_tura tt ON tuo.Id = tt.idOrganizacije
   									 JOIN Rezervacija r ON tt.Id = r.idTure
    								JOIN Ocena o ON r.Id = o.idRezervacije
    WHERE tuo.Id = id_organizacije AND r.Status_rezervacije = 'Realizovana';
    RETURN prosek;
END;
$$;

---Broj realizovanih putovanja---
CREATE FUNCTION broj_realizovanih_putovanja(
    id_organizacije INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE broj_putovanja INT =0;
BEGIN
    SELECT COUNT(*) INTO broj_putovanja
    FROM Rezervacija r JOIN Turisticka_tura tt ON r.idTure = tt.Id
    WHERE tt.idOrganizacije = id_organizacije AND r.Status_rezervacije = 'Realizovana';
    RETURN broj_putovanja;
END;
$$;

---Broj rezervacija po organizaciji---
CREATE FUNCTION broj_rezervacija_po_organizaciji(
    id_organizacije INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    broj_rezervacija INT =0;
BEGIN
    SELECT COUNT(*) INTO broj_rezervacija
    FROM Turisticka_organizacija o JOIN Turisticka_tura t ON o.Id = t.idOrganizacije
    JOIN Rezervacija r ON t.Id = r.idTure
    WHERE o.Id = id_organizacije;
    RETURN broj_rezervacija;
END;
$$;

---Broj putnika po organizaciji---
CREATE FUNCTION broj_putnika_po_organizaciji(
    id_organizacije INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    broj_putnika INT =0;
BEGIN
    SELECT COUNT(rp.idPutnika)
    INTO broj_putnika
    FROM Turisticka_organizacija o JOIN Turisticka_tura t ON o.Id = t.idOrganizacije
    JOIN Rezervacija r ON t.Id = r.idTure
    JOIN Rezervacija_putnik rp ON r.Id = rp.idRezervacije
    WHERE o.Id = id_organizacije AND r.Status_rezervacije = 'Realizovana';
    RETURN broj_putnika;
END;
$$;

---Broj rezervacija po destinaciji---
CREATE FUNCTION broj_rezervacija_po_destinaciji(
    id_destinacije INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    broj_rezervacija INT =0;
BEGIN
    SELECT COUNT(*) INTO broj_rezervacija
    FROM Destinacija d JOIN Turisticka_tura t ON d.Id = t.idDestinacije
    JOIN Rezervacija r ON t.Id = r.idTure
    WHERE d.Id = id_destinacije AND r.Status_rezervacije <> 'Otkazana';
    RETURN broj_rezervacija;
END;
$$;

---Prihod turističke organizacije---
CREATE FUNCTION prihod_turisticke_organizacije(
    id_organizacije INT
)
RETURNS NUMERIC(12,2)
LANGUAGE plpgsql
AS $$
DECLARE
    prihod NUMERIC(12,2);
BEGIN
    SELECT COALESCE(SUM(t.Cena), 0) INTO prihod
    FROM Turisticka_organizacija o JOIN Turisticka_tura t ON o.Id = t.idOrganizacije
    JOIN Rezervacija r ON t.Id = r.idTure
    WHERE o.Id = id_organizacije AND r.Status_placanja = 'Plaćena' AND r.Status_rezervacije = 'Realizovana';
    RETURN prihod;
END;
$$;

---datum rodjenja--
CREATE FUNCTION datum_rodjenja_iz_jmbg(
    jmbg CHAR(13)
)
RETURNS DATE
LANGUAGE plpgsql
AS $$
DECLARE
    dan INT;
    mesec INT;
    godina_jmbg INT;
    trenutna_godina INT;
    godina INT;
BEGIN
    dan := SUBSTRING(jmbg FROM 1 FOR 2)::INT;
    mesec := SUBSTRING(jmbg FROM 3 FOR 2)::INT;
    godina_jmbg := SUBSTRING(jmbg FROM 5 FOR 3)::INT;
    trenutna_godina := EXTRACT(YEAR FROM CURRENT_DATE)::INT;
    godina := 1900 + godina_jmbg;
    IF godina + 100 > trenutna_godina THEN
        godina := 2000 + godina_jmbg;
    END IF;
    RETURN MAKE_DATE(godina, mesec, dan);
END;
$$;
---da li je punoletan---
CREATE FUNCTION punoletan(
    jmbg CHAR(13)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN datum_rodjenja_iz_jmbg(jmbg) <= CURRENT_DATE - INTERVAL '18 years';
END;
$$;