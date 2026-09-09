---Sprecavanje rezervacije ako nema dovoljno mesta---
CREATE FUNCTION proveri_dostupnost_mesta()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    idTureRezervacije INT;
BEGIN
    SELECT idTure INTO idTureRezervacije
    FROM Rezervacija
    WHERE Id = NEW.idRezervacije;
    IF broj_slobodnih_mesta(idTureRezervacije) <= 0 THEN
        RAISE EXCEPTION 'Nema dovoljno slobodnih mesta na izabranoj turističkoj turi';
    END IF;
    RETURN NEW;
END;
$$;

---Sprecavanje da isti putnik bude na dve ture koje se preklapaju---
CREATE FUNCTION proveri_preklapanje_tura_putnika()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    datumPocetkaNoveTure TIMESTAMP;
    datumKrajaNoveTure TIMESTAMP;
BEGIN
    SELECT tt.Datum_pocetka, tt.Datum_kraja INTO datumPocetkaNoveTure, datumKrajaNoveTure
    FROM Rezervacija r JOIN Turisticka_tura tt ON r.idTure = tt.Id
    WHERE r.Id = NEW.idRezervacije;
    IF EXISTS (
        SELECT 1
        FROM Rezervacija_putnik rp JOIN Rezervacija r ON rp.idRezervacije = r.Id
        							JOIN Turisticka_tura tt ON r.idTure = tt.Id
        WHERE rp.idPutnika = NEW.idPutnika AND rp.idRezervacije <> NEW.idRezervacije
          AND r.Aktivan = TRUE AND r.Status_rezervacije <> 'Otkazana' AND tt.Aktivan = TRUE
          AND tt.Datum_pocetka < datumKrajaNoveTure AND tt.Datum_kraja > datumPocetkaNoveTure
    )
    THEN
        RAISE EXCEPTION 'Putnik već ima rezervaciju za turističku turu koja se vremenski preklapa sa izabranom turom';
    END IF;
    RETURN NEW;
END;
$$;