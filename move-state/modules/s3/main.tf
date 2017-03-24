variable "name" {
  description = "Name of the S3 bucket"
  type = "string"
}

variable "acl" {
  description = "Acl type of S3 bucket"
  type = "string"
  default = "private"
}

resource "aws_s3_bucket" "s3" {
  bucket = "${var.name}"
  acl    = "private"

  tags {
    Name        = "${var.name}"
  }
}
