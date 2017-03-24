variable "enable_internet" {
  description = "If set to true, enable Internet Gateway"
  default     = false
}

resource "aws_vpc" "main" {
  cidr_block = "10.240.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  count = "${var.enable_internet}"

  vpc_id = "${aws_vpc.main.id}"
}
