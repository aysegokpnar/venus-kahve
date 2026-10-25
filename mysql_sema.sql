-- Venüs Kahve: MySQL şeması (Azure Database for MySQL, Flexible Server, 8.4)
-- Sıra önemli: önce bağımsız tablolar, sonra yabancı anahtarlı tablolar.

SET NAMES utf8mb4;
CREATE DATABASE venus_db CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci;
USE venus_db;

CREATE TABLE musteri (
  musteri_id INT AUTO_INCREMENT PRIMARY KEY,
  tip ENUM('bireysel','kafe') NOT NULL,
  ad VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  telefon VARCHAR(20),
  sehir VARCHAR(60) NOT NULL,
  kayit_tarihi DATE NOT NULL
);

CREATE TABLE tedarikci (
  tedarikci_id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(120) NOT NULL,
  ulke VARCHAR(60) NOT NULL,
  email VARCHAR(150)
);

CREATE TABLE urun (
  urun_id INT AUTO_INCREMENT PRIMARY KEY,
  urun_kodu VARCHAR(30) NOT NULL UNIQUE,
  ad VARCHAR(150) NOT NULL,
  kategori ENUM('kahve','ekipman','aksesuar') NOT NULL,
  birim_fiyat DECIMAL(10,2) NOT NULL CHECK (birim_fiyat > 0),
  aktif TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE parti (
  parti_id INT AUTO_INCREMENT PRIMARY KEY,
  urun_id INT NOT NULL,
  tedarikci_id INT NOT NULL,
  kavurma_tarihi DATE NOT NULL,
  son_kullanma_tarihi DATE NOT NULL,
  uretilen_adet INT NOT NULL CHECK (uretilen_adet > 0),
  kalan_adet INT NOT NULL CHECK (kalan_adet >= 0),
  CONSTRAINT fk_parti_urun FOREIGN KEY (urun_id) REFERENCES urun(urun_id),
  CONSTRAINT fk_parti_tedarikci FOREIGN KEY (tedarikci_id) REFERENCES tedarikci(tedarikci_id)
);

CREATE TABLE siparis (
  siparis_id INT AUTO_INCREMENT PRIMARY KEY,
  musteri_id INT NOT NULL,
  siparis_tarihi DATE NOT NULL,
  durum ENUM('beklemede','hazirlaniyor','yolda','teslim_edildi','iptal') NOT NULL DEFAULT 'beklemede',
  toplam_tutar DECIMAL(12,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_siparis_musteri FOREIGN KEY (musteri_id) REFERENCES musteri(musteri_id)
);

-- Sipariş silinirse kalemleri de silinir (ON DELETE CASCADE)
CREATE TABLE siparis_kalem (
  kalem_id INT AUTO_INCREMENT PRIMARY KEY,
  siparis_id INT NOT NULL,
  urun_id INT NOT NULL,
  parti_id INT NULL,
  adet INT NOT NULL CHECK (adet > 0),
  birim_fiyat DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_kalem_siparis FOREIGN KEY (siparis_id) REFERENCES siparis(siparis_id) ON DELETE CASCADE,
  CONSTRAINT fk_kalem_urun FOREIGN KEY (urun_id) REFERENCES urun(urun_id),
  CONSTRAINT fk_kalem_parti FOREIGN KEY (parti_id) REFERENCES parti(parti_id)
);

CREATE INDEX idx_siparis_tarih ON siparis(siparis_tarihi);
CREATE INDEX idx_siparis_musteri ON siparis(musteri_id);
CREATE INDEX idx_parti_skt ON parti(son_kullanma_tarihi);
