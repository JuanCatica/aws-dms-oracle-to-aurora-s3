resource "aws_s3_bucket" "bucket_target" {
  bucket = var.target_s3_bucket_name
  acl    = "private"

  tags = {
    Name    = "bucket_target"
    project = "oracle2aurora"
  }
}
