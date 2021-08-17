#locals {
#  custom_origin_id = "Custom-${terraform.workspace}.${var.domain_name}"
#}

locals {
  behaviors = {
    images = {
      target_origin_id = aws_s3_bucket.front.id
      path = "/images/*"
    },
    static = {
      target_origin_id = aws_s3_bucket.front.id
      path = "/static/*"
    }
  }
}

# CloudFront Distributionsの設定
resource "aws_cloudfront_distribution" "main" {
  # Origins and Origin Groups の設定
  origin {
    domain_name = aws_s3_bucket.front.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.front.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_identity.cloudfront_access_identity_path
    }
  }
  origin {
    domain_name = "${terraform.workspace}.${var.domain_name}"
    origin_id   = "Custom-${terraform.workspace}.${var.domain_name}"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.1"]
    }
  }

  # Behaviors　の設定(必須）
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.front.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Behaviors　の設定(二個目以降の設定)
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "Custom-${terraform.workspace}.${var.domain_name}"
    forwarded_values {
      query_string = true
      headers = ["Authorization"]
      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.behaviors

    content {
      path_pattern     = ordered_cache_behavior.value["path"]
      target_origin_id = ordered_cache_behavior.value["target_origin_id"]
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      forwarded_values {
        query_string = false
        cookies {
          forward = "none"
        }
      }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    }
  }

  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL証明書の設定(defaultのcloudfront証明書を使う設定になっている)
  #viewer_certificate {
  #  cloudfront_default_certificate = false
  #}
  # 設定済みのACMを利用するように設定
  viewer_certificate {
    acm_certificate_arn = var.acm_arm
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
  # エイリアス ACMに当てはまるドメイン名である必要がある
  aliases = ["dev.improlife.net"]

  # Error Pages の設定
  custom_error_response {
    error_caching_min_ttl = 0   # デフォルトの5分間を明示的に指定。
    error_code            = 403 # カスタマイズしたいエラーコードを指定する。
    response_code         = 200 # Viewerに返したいコードを指定する。
    response_page_path    = "/index.html"
  }
}

# s3へのアクセスポリシーを設定するための記述
resource "aws_cloudfront_origin_access_identity" "access_identity" {}
