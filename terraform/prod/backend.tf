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
    #dynamodb_table              = "reddit-prod"
  }
}

#resource "aws_dynamodb_table" "reddit-prod" {
#  name             = "example"
#  billing_mode   = "PROVISIONED"
#  read_capacity  = 20
#  write_capacity = 20
#  hash_key       = "LockID"
#  attribute {
#    name = "LockID"
#    type = "S"
#  }
#}
