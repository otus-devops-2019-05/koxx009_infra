variable project {
  description = "Project ID"
}

variable region {
  description = "Region"

  # Значение по умолчанию
  default = "europe-west3"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable private_key {
  description = "Path to the private key used for ssh connection"
}

variable zone {
  description = "Enter zone"
  default     = "europe-west3-c"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base-1562523004"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-1562522781"
}
