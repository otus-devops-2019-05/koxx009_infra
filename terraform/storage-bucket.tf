provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"

  # Имена поменяйте на другие
  name = ["st-bucket-test-1", "st-bucket-test-2"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
