resource "aws_s3_bucket" "terraform_remote_state" {
  bucket = "terraform-amazon-eks-cluster"
}
