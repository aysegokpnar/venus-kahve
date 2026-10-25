-- Venüs Kahve: örnek veri
-- Önce mysql_sema.sql çalıştırılmış olmalı.

SET NAMES utf8mb4;
USE venus_db;

INSERT INTO tedarikci (ad, ulke, email) VALUES
 ('Yeşil Çekirdek İthalat','Türkiye','siparis@yesilcekirdek.example'),
 ('Andes Coffee Traders','Kolombiya','sales@andes.example'),
 ('Rift Valley Exports','Kenya','export@riftvalley.example');

INSERT INTO musteri (tip, ad, email, telefon, sehir, kayit_tarihi) VALUES
 ('bireysel','Elif Arslan','elif.arslan@example.com','05320000001','İzmir','2026-06-10'),
 ('bireysel','Mert Kaya','mert.kaya@example.com','05320000002','İstanbul','2026-07-02'),
 ('bireysel','Zeynep Aydın','zeynep.aydin@example.com','05320000003','Ankara','2026-09-14'),
 ('kafe','Kıyı Kahve','siparis@kiyikahve.example','02320000004','İzmir','2026-05-20'),
 ('kafe','Çınar Espresso','info@cinarespresso.example','02320000005','İzmir','2026-06-01'),
 ('kafe','Alsancak Kitap Kafe','merhaba@alsancakkitap.example','02320000006','İzmir','2026-08-18');

INSERT INTO urun (urun_kodu, ad, kategori, birim_fiyat) VALUES
 ('KHV-ETH-250','Etiyopya Yirgacheffe 250 g','kahve',185.00),
 ('KHV-KOL-250','Kolombiya Supremo 250 g','kahve',165.00),
 ('KHV-BRZ-250','Brezilya Santos 250 g','kahve',145.00),
 ('KHV-HSE-1000','Venüs Ev Harmanı 1 kg','kahve',520.00),
 ('EKP-V60-01','V60 Seramik Dripper','ekipman',390.00),
 ('AKS-FLT-100','V60 Kağıt Filtre (100''lü)','aksesuar',95.00),
 ('EKP-GRN-01','El Değirmeni','ekipman',1450.00),
 ('KHV-KEN-250','Kenya AA 250 g','kahve',210.00);

INSERT INTO parti (urun_id, tedarikci_id, kavurma_tarihi, son_kullanma_tarihi, uretilen_adet, kalan_adet) VALUES
 (1,1,'2026-09-20','2027-06-20',120,85),
 (2,2,'2026-09-22','2027-06-22',100,70),
 (3,2,'2026-06-15','2026-11-02',80,12),
 (4,1,'2026-10-01','2027-07-01',60,40),
 (8,3,'2026-10-03','2027-07-03',50,38);

INSERT INTO siparis (musteri_id, siparis_tarihi, durum) VALUES
 (1,'2026-07-12','teslim_edildi'),
 (4,'2026-08-03','teslim_edildi'),
 (5,'2026-08-20','teslim_edildi'),
 (2,'2026-09-05','teslim_edildi'),
 (4,'2026-10-02','yolda'),
 (6,'2026-10-06','hazirlaniyor'),
 (3,'2026-10-07','beklemede');

-- Kafelere %10 indirimli fiyat uygulandı
INSERT INTO siparis_kalem (siparis_id, urun_id, parti_id, adet, birim_fiyat) VALUES
 (1,1,NULL,2,185.00),(1,5,NULL,1,390.00),
 (2,4,NULL,10,468.00),(2,3,NULL,12,130.50),
 (3,4,NULL,8,468.00),(3,6,NULL,5,85.50),
 (4,2,NULL,1,165.00),(4,7,NULL,1,1450.00),
 (5,4,4,6,468.00),(5,1,1,10,166.50),
 (6,8,5,4,189.00),(6,2,2,6,148.50),
 (7,1,1,3,185.00);

-- Sipariş toplamlarını kalemlerden hesapla
UPDATE siparis s
SET toplam_tutar = (SELECT SUM(k.adet*k.birim_fiyat) FROM siparis_kalem k WHERE k.siparis_id = s.siparis_id);

-- Beklenen satır sayıları: musteri 6, urun 8, parti 5, siparis 7, siparis_kalem 13
SELECT 'musteri' AS tablo, COUNT(*) AS satir FROM musteri
UNION ALL SELECT 'urun', COUNT(*) FROM urun
UNION ALL SELECT 'parti', COUNT(*) FROM parti
UNION ALL SELECT 'siparis', COUNT(*) FROM siparis
UNION ALL SELECT 'siparis_kalem', COUNT(*) FROM siparis_kalem;
