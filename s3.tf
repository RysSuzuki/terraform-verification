resource "aws_s3_bucket" "front" {
  # バケット名＋自動で値が振られて一意の名称になる
  bucket_prefix = "front"
  acl           = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_policy" "front" {
  bucket = aws_s3_bucket.front.id
  policy = data.aws_iam_policy_document.backet_policy.json
}

data "aws_iam_policy_document" "backet_policy" {
  statement {
    sid    = "Allow CloudFront"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.access_identity.iam_arn]
    }
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.front.arn}/*"
    ]
  }
}
