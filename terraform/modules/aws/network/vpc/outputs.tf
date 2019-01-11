output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "vpc_s3_endpoint_id" {
  value = "${aws_vpc_endpoint.s3.id}"
}
