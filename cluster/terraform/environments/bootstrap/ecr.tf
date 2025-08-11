resource "aws_ecr_repository" "repos" {
  for_each             = toset(var.ecr_repos)
  name                 = lower(each.value)
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = var.enable_kms_encryption ? "KMS" : "AES256"
    kms_key         = var.enable_kms_encryption ? var.kms_key_arn : null
  }

  tags = local.tags
}

# Keep most recent 10 images; expire untagged after 7 days
resource "aws_ecr_lifecycle_policy" "repos" {
  for_each   = aws_ecr_repository.repos
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images after 7 days",
        selection    = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 7
        },
        action = { type = "expire" }
      },
      {
        rulePriority = 2,
        description  = "Keep last 10 images for any tag",
        selection    = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = { type = "expire" }
      }
    ]
  })
}