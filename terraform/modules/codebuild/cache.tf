resource "aws_s3_bucket" "codebuild_s3_cache" {
  bucket        = "${var.name}-codebuild-cache"
  force_destroy = true
}
