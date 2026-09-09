--- Aktivne i buduće turističke ture ---

CREATE VIEW Aktivne_buduce_ture AS
SELECT  d.Naziv AS Destinacija,d.Kategorija,m.Naziv AS Mesto,d.Opis AS Opis_destinacije,tuo.Naziv AS Turisticka_organizacija,p.Naziv AS Prevoz,s.Naziv AS Smestaj,tt.Datum_pocetka,tt.Datum_kraja,tt.Cena,tt.BrojMesta AS Ukupan_broj_mesta,broj_slobodnih_mesta(tt.Id) AS Broj_slobodnih_mesta,tt.Opis AS Opis_ture
FROM Turisticka_tura tt JOIN Destinacija d ON tt.idDestinacije = d.Id
						JOIN Mesto m  ON d.Id_mesta = m.Id
						JOIN Turisticka_organizacija tuo ON tt.idOrganizacije = tuo.Id
						JOIN Prevoz p ON tt.idPrevoza = p.Id
						LEFT JOIN Smestaj s ON tt.idSmestaja = s.Id
WHERE tt.Aktivan = TRUE AND d.Aktivan = TRUE AND tuo.Aktivan = TRUE AND tt.Datum_pocetka > CURRENT_TIMESTAMP;

--- Popunjenost turističkih tura ---

CREATE VIEW Popunjenost_tura AS
SELECT tuo.Naziv AS Turisticka_organizacija,d.Naziv AS Destinacija,m.Naziv AS Mesto,tt.Datum_pocetka,tt.Datum_kraja,tt.BrojMesta AS Ukupan_broj_mesta,broj_zauzetih_mesta(tt.Id) AS Broj_putnika,broj_slobodnih_mesta(tt.Id) AS Broj_slobodnih_mesta
FROM Turisticka_tura tt JOIN Turisticka_organizacija tuo ON tt.idOrganizacije = tuo.Id
						JOIN Destinacija d ON tt.idDestinacije = d.Id
						JOIN Mesto m ON d.Id_mesta = m.Id;


--- Detaljan pregled svih rezervacija ---

CREATE VIEW Pregled_rezervacija AS
SELECT r.Broj_rezervacije,k.Ime || ' ' || k.Prezime AS Nosilac_rezervacije,k.Email AS Email_nosioca,tuo.Naziv AS Turisticka_organizacija,d.Naziv AS Destinacija,m.Naziv AS Mesto,tt.Datum_pocetka,tt.Datum_kraja,tt.Cena,r.Status_placanja,r.Status_rezervacije,r.Datum_kreiranja,r.Datum_uplate
FROM Rezervacija r JOIN Korisnik k ON r.Id_nosioca_rezervacije = k.Id
				JOIN Turisticka_tura tt ON r.idTure = tt.Id
				JOIN Turisticka_organizacija tuo ON tt.idOrganizacije = tuo.Id
				JOIN Destinacija d ON tt.idDestinacije = d.Id
				JOIN Mesto m ON d.Id_mesta = m.Id;

--- Putnici po rezervaciji ---

CREATE VIEW Putnici_po_rezervaciji AS
SELECT r.Broj_rezervacije,p.Ime,p.Prezime,p.Jmbg,p.Broj_telefona,m.Naziv AS Mesto_stanovanja,p.Adresa_stanovanja,rp.Status_putnika,
    CASE 
        WHEN p.Saglasnost IS NULL THEN 'Nije potrebna'
        ELSE p.Saglasnost
    END AS Saglasnost
FROM Rezervacija r JOIN Rezervacija_putnik rp ON r.Id = rp.idRezervacije
					JOIN Putnik p ON rp.idPutnika = p.Id
					JOIN Mesto m ON p.Id_mestaStanovanja = m.Id;

---Aktivne turističke organizacije i njihovi menadžeri---

CREATE VIEW Organizacije_i_menadzeri AS
SELECT tuo.Naziv AS Turisticka_organizacija,tuo.Email,tuo.Broj_telefona,
k.Ime || ' ' || k.Prezime AS Menadzer,k.Email AS Email_menadzera
FROM Turisticka_organizacija tuo JOIN Korisnik k ON tuo.idMenadzera = k.Id
WHERE tuo.Aktivan=TRUE;


--- Najposećenije destinacije ---

CREATE VIEW Najposecenije_destinacije AS
SELECT d.Naziv AS Destinacija,m.Naziv AS Mesto,d.Kategorija,d.Opis,COUNT(r.Id) AS Broj_realizovanih_rezervacija
FROM Destinacija d JOIN Mesto m ON d.Id_mesta = m.Id
					JOIN Turisticka_tura tt ON d.Id = tt.idDestinacije
					JOIN Rezervacija r ON tt.Id = r.idTure
WHERE r.Status_rezervacije = 'Realizovana'AND d.Aktivan = TRUE
GROUP BY d.Id,d.Naziv,m.Naziv,d.Kategorija,d.Opis
ORDER BY Broj_realizovanih_rezervacija DESC;


--- Rang-lista turističkih organizacija ---

CREATE VIEW Rang_lista_organizacija AS
SELECT tuo.Naziv AS Turisticka_organizacija,tuo.Broj_telefona,tuo.Email,k.Ime || ' ' || k.Prezime AS Menadzer,ROUND(AVG(o.Ocena), 2) AS Prosecna_ocena,COUNT(o.Id) AS Broj_ocena
FROM Turisticka_organizacija tuo JOIN Korisnik k ON tuo.idMenadzera = k.Id
								JOIN Turisticka_tura tt ON tuo.Id = tt.idOrganizacije
								JOIN Rezervacija r ON tt.Id = r.idTure
								JOIN Ocena o ON r.Id = o.idRezervacije
WHERE tuo.Aktivan = TRUE AND r.Status_rezervacije = 'Realizovana'
GROUP BY tuo.Id,tuo.Naziv,tuo.Broj_telefona,tuo.Email,k.Ime,k.Prezime
ORDER BY Prosecna_ocena DESC,Broj_ocena DESC;

---Organizacije i broj realizovanih putovanja---
CREATE VIEW Statistika_organizacija AS
SELECT tuo.Naziv AS Turisticka_organizacija,
COUNT(DISTINCT tt.Id) AS Broj_tura, COUNT(DISTINCT r.Id) AS Broj_realizovanih_rezervacija,COUNT(DISTINCT rp.idPutnika) AS Broj_putnika
FROM Turisticka_organizacija tuo LEFT JOIN Turisticka_tura tt ON tuo.Id = tt.idOrganizacije
								LEFT JOIN Rezervacija r ON tt.Id = r.idTure AND r.Status_rezervacije = 'Realizovana'
								LEFT JOIN Rezervacija_putnik rp ON r.Id = rp.idRezervacije
WHERE tuo.Aktivan = TRUE
GROUP BY tuo.Id,tuo.Naziv;