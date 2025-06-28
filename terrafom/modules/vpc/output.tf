output "vpc_id" {
    description = "ID of the VPC"
    value = aws_vpc.main.id
}

output "priv_sub_ids" {
    description = "ID of the VPC"
    value = aws_subnet.private-subnet[*].id
}

output "pub_sub_ids" {
    description = "ID of the VPC"
    value = aws_subnet.public-subnet[*].id
}