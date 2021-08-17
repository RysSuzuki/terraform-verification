resource "aws_s3_bucket_object" "index_page" {
  bucket       = aws_s3_bucket.front.id
  key          = "index.html"
  source       = "www/index.html"
  content_type = "text/html"
  etag         = filemd5("www/index.html")
}