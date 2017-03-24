resource "aws_s3_bucket" "my-bucket" {
  bucket = "${var.name}"
  acl    = "private"

  tags {
    Name        = "${var.name}"
  }
}

/*
module "my-bucket" {
  source = "modules/s3"

  name = "tf-my-bucket"
  acl = "private"
}
*/
