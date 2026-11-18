resource "aws_s3_bucket" "codebuild_s3_cache" {
  #checkov:skip=CKV2_AWS_6:Build cache buckets are private and accessed only by the CodeBuild role.
  #checkov:skip=CKV2_AWS_61:Build cache is disposable; lifecycle expiry is not required for this workload.
  #checkov:skip=CKV2_AWS_62:Cache buckets do not require event-driven integrations.
  #checkov:skip=CKV_AWS_18:Build cache contains reproducible artifacts and does not require access logging.
  #checkov:skip=CKV_AWS_21:Build cache is disposable and does not require version history.
  #checkov:skip=CKV_AWS_144:Build cache is regional and does not require cross-region replication.
  #checkov:skip=CKV_AWS_145:Uses S3-managed encryption; a customer-managed KMS key is not configured.
  bucket        = "${var.name}-codebuild-cache"
  force_destroy = true
}
