#resource "yandex_storage_bucket" "reddit-bucket" {
#  bucket = "isie-ter-bucket"
#}

terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "isie-ter-bucket"
    key                         = "reddit/reddit-prod.tfstate"
    region                      = "us-east-1"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
