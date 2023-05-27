output "repository_url" {
  value = aws_ecr_repository.app_repository.repository_url
}

output "registry_id" {
  value = aws_ecr_repository.app_repository.registry_id
}

output "arn" {
  value = aws_ecr_repository.app_repository.arn
}
