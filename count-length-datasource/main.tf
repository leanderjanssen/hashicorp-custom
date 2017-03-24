data "aws_availability_zones" "all" {}

resource "aws_vpc" "main" {
  cidr_block = "10.240.0.0/16"
}

resource "aws_subnet" "main" {
  count             = "${length(data.aws_availability_zones.all.names)}"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)}"
}

output "az" {
  value = "${data.aws_availability_zones.all.names}"
}
