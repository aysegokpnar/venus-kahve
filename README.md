# Venüs Kahve

Venüs Kahve, kurgusal bir kahve üreticisidir. Bireysel ve kurumsal müşterileri vardır. Çekilmiş kahve, kahve çekirdeklerinin yanı sıra kahve ekipmanlarının üretimini, tedariğini ve satışını yapar. Tüm veriler kurgusaldır.

## Mimari

| Katman | Servis | Rol |
|---|---|---|
| İlişkisel veritabanı | Azure Database for MySQL (Flexible Server) | Müşteri, ürün, parti, sipariş (ERP çekirdeği) |
| Belge veritabanı | Azure Cosmos DB for NoSQL | Müşteri etkileşimleri, ürün özellikleri (CRM yanı) |

## Dosyalar

| Dosya | İçerik |
|---|---|
| `mysql_sema.sql` | Veritabanı ve 6 tablo (anahtarlar, kısıtlar, indeksler) |
| `mysql_ornek_veri.sql` | Örnek müşteri, ürün, parti, sipariş verisi |
| `mysql_sorgular.sql` | SELECT, INSERT (transaction), UPDATE, DELETE örnekleri |
| `cosmos_etkilesimler.json` | Müşteri etkileşim belgeleri |
| `cosmos_urun_ozellikleri.json` | Ürün özellik belgeleri |
| `cosmos_yukle.py` | JSON dosyalarını Cosmos DB'ye yükleyen Python betiği |

## Kullanım

MySQL dosyalarını sırayla çalıştırın: `mysql_sema.sql`, `mysql_ornek_veri.sql`, `mysql_sorgular.sql`.

Cosmos DB yüklemesi için kimlik bilgilerini ortam değişkeni olarak verin (koda veya bu depoya yazmayın):

```
pip install azure-cosmos
export COSMOS_ENDPOINT="https://<hesap-adi>.documents.azure.com:443/"
export COSMOS_KEY="<primary-key>"
python cosmos_yukle.py
```

## Güvenlik

Bu depoda parola, anahtar veya sunucu yönetici bilgisi yoktur ve olmamalıdır.
