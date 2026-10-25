"""Venüs Kahve: JSON belgelerini Azure Cosmos DB'ye yükler (Azure Cosmos SDK örneği).

Kimlik bilgileri koda yazılmaz; ortam değişkenlerinden okunur:
    export COSMOS_ENDPOINT="https://<hesap-adi>.documents.azure.com:443/"
    export COSMOS_KEY="<primary-key>"

Kullanım:
    pip install azure-cosmos
    python cosmos_yukle.py
"""
import json
import os
import sys

from azure.cosmos import CosmosClient

VERITABANI = "venus-crm"
YUKLEMELER = [
    ("etkilesimler", "cosmos_etkilesimler.json"),
    ("urun-ozellikleri", "cosmos_urun_ozellikleri.json"),
]


def main():
    endpoint = os.environ.get("COSMOS_ENDPOINT")
    key = os.environ.get("COSMOS_KEY")
    if not endpoint or not key:
        sys.exit("Hata: COSMOS_ENDPOINT ve COSMOS_KEY ortam değişkenleri ayarlanmamış.")

    client = CosmosClient(endpoint, credential=key)
    veritabani = client.get_database_client(VERITABANI)

    for konteyner_adi, dosya in YUKLEMELER:
        konteyner = veritabani.get_container_client(konteyner_adi)
        with open(dosya, encoding="utf-8") as f:
            belgeler = json.load(f)
        for belge in belgeler:
            konteyner.upsert_item(belge)  # varsa günceller, yoksa ekler
        print(f"{konteyner_adi}: {len(belgeler)} belge yüklendi")


if __name__ == "__main__":
    main()
