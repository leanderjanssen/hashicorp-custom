provider "aws" {
  region = "${var.region}"
  profile = "${var.env}"
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.assume_account}:role/${var.assume_role}"
    session_name = "tf-session"
  }
}
