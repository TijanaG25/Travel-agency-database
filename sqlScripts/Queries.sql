---Rezervacije jednog korisnika---

SELECT r.Broj_rezervacije, r.Status_placanja, r.Status_rezervacije, r.Datum_kreiranja, r.Datum_uplate, tt.Datum_pocetka, tt.Datum_kraja, d.Naziv AS Destinacija, m.Naziv as Mesto, tuo.Naziv AS Turisticka_organizacija
FROM Rezervacija r JOIN Turisticka_tura tt ON r.idTure = tt.Id
					JOIN Destinacija d ON tt.idDestinacije = d.Id
					JOIN Mesto m ON m.Id=d.id_mesta
					JOIN Turisticka_organizacija tuo ON tt.idOrganizacije = tuo.Id
WHERE r.Id_nosioca_rezervacije = 1
ORDER BY tt.Datum_pocetka DESC;

---Putnici određene rezervacije---

SELECT r.Broj_rezervacije, p.Ime, p.Prezime, p.Jmbg, m.Naziv AS Mesto_stanovanja, rp.Status_putnika
FROM Rezervacija r JOIN Rezervacija_putnik rp ON r.Id = rp.idRezervacije
					JOIN Putnik p ON rp.idPutnika = p.Id
					JOIN Mesto m ON p.Id_mestaStanovanja = m.Id
WHERE r.Id = 1;