-- Venüs Kahve: örnek sorgular (SELECT, INSERT, UPDATE, DELETE)
-- Önce mysql_sema.sql ve mysql_ornek_veri.sql çalıştırılmış olmalı.

SET NAMES utf8mb4;
USE venus_db;

-- 1. Son 3 ayda en çok harcayan kafeler (JOIN + GROUP BY)
SELECT m.ad AS kafe, COUNT(DISTINCT s.siparis_id) AS siparis_sayisi, SUM(s.toplam_tutar) AS toplam_harcama
FROM musteri m
JOIN siparis s ON s.musteri_id = m.musteri_id
WHERE m.tip = 'kafe'
  AND s.durum <> 'iptal'
  AND s.siparis_tarihi >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY m.musteri_id, m.ad
ORDER BY toplam_harcama DESC
LIMIT 5;

-- 2. Son kullanma tarihine 30 günden az kalan partiler
SELECT p.parti_id, u.ad AS urun, p.son_kullanma_tarihi,
       DATEDIFF(p.son_kullanma_tarihi, CURDATE()) AS kalan_gun, p.kalan_adet
FROM parti p
JOIN urun u ON u.urun_id = p.urun_id
WHERE p.kalan_adet > 0
  AND p.son_kullanma_tarihi <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY p.son_kullanma_tarihi;

-- 3. Aylık satış ve kategoriye göre dağılım
SELECT DATE_FORMAT(s.siparis_tarihi, '%Y-%m') AS ay,
       u.kategori,
       SUM(k.adet * k.birim_fiyat) AS ciro
FROM siparis s
JOIN siparis_kalem k ON k.siparis_id = s.siparis_id
JOIN urun u ON u.urun_id = k.urun_id
WHERE s.durum <> 'iptal'
GROUP BY ay, u.kategori
ORDER BY ay, u.kategori;

-- 4. Stoğu 20 adedin altındaki partiler
SELECT p.parti_id, u.urun_kodu, u.ad, p.kalan_adet
FROM parti p JOIN urun u ON u.urun_id = p.urun_id
WHERE p.kalan_adet < 20
ORDER BY p.kalan_adet;

-- 5. Hiç sipariş vermemiş müşteriler (LEFT JOIN; sonuç boş çıkabilir)
SELECT m.musteri_id, m.ad, m.tip
FROM musteri m
LEFT JOIN siparis s ON s.musteri_id = m.musteri_id
WHERE s.siparis_id IS NULL;

-- 6. En çok satan ürünler
SELECT u.ad, SUM(k.adet) AS toplam_adet, SUM(k.adet * k.birim_fiyat) AS ciro
FROM siparis_kalem k JOIN urun u ON u.urun_id = k.urun_id
GROUP BY u.urun_id, u.ad
ORDER BY toplam_adet DESC;

-- 7. Yeni müşteri ekle
INSERT INTO musteri (tip, ad, email, telefon, sehir, kayit_tarihi)
VALUES ('kafe', 'Karşıyaka Moka', 'info@karsiyakamoka.example', '02320000007', 'İzmir', CURDATE());
SELECT * FROM musteri WHERE email = 'info@karsiyakamoka.example';

-- 8. Yeni sipariş: tek transaction (sipariş + kalem + stok düşümü)
-- START TRANSACTION ile COMMIT arasındaki her şey ya birlikte olur ya da hiç olmaz.
START TRANSACTION;
SET @yeni_musteri = (SELECT musteri_id FROM musteri WHERE email = 'info@karsiyakamoka.example');
INSERT INTO siparis (musteri_id, siparis_tarihi, durum) VALUES (@yeni_musteri, CURDATE(), 'beklemede');
SET @yeni_siparis = LAST_INSERT_ID();
INSERT INTO siparis_kalem (siparis_id, urun_id, parti_id, adet, birim_fiyat)
VALUES (@yeni_siparis, 4, 4, 5, 468.00);
UPDATE parti SET kalan_adet = kalan_adet - 5 WHERE parti_id = 4 AND kalan_adet >= 5;
UPDATE siparis
SET toplam_tutar = (SELECT SUM(adet * birim_fiyat) FROM siparis_kalem WHERE siparis_id = @yeni_siparis)
WHERE siparis_id = @yeni_siparis;
COMMIT;

-- Beklenen: yeni siparişin toplamı 2340.00, parti 4'ün kalan adedi 35 (40 - 5)
SELECT * FROM siparis WHERE siparis_id = @yeni_siparis;
SELECT parti_id, kalan_adet FROM parti WHERE parti_id = 4;

-- 9. Güncelleme (UPDATE)
UPDATE siparis SET durum = 'yolda' WHERE siparis_id = 6;
SELECT siparis_id, durum FROM siparis WHERE siparis_id = 6;

UPDATE urun SET birim_fiyat = 150.00 WHERE urun_kodu = 'KHV-BRZ-250';
SELECT urun_kodu, birim_fiyat FROM urun WHERE urun_kodu = 'KHV-BRZ-250';

-- 10. Silme (DELETE)
-- 10.1 Siparişi sil: ON DELETE CASCADE kalemleri de siler (beklenen: kalan_kalem = 0)
DELETE FROM siparis WHERE siparis_id = @yeni_siparis;
SELECT COUNT(*) AS kalan_kalem FROM siparis_kalem WHERE siparis_id = @yeni_siparis;

-- 10.2 Yabancı anahtar koruması: siparişi olan müşteri silinemez.
-- Hata vermesi beklenen davranış: "Cannot delete or update a parent row: a foreign key constraint fails"
DELETE FROM musteri WHERE musteri_id = 4;

-- 10.3 Siparişi olmayan müşteriyi sil (beklenen satır sayısı: 6)
DELETE FROM musteri WHERE email = 'info@karsiyakamoka.example';
SELECT COUNT(*) AS satir FROM musteri;
