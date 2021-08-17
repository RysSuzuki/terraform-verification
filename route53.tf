# cloudfrontでサブドメインを使う方法
# 1.バージニア北部でacmを作成する
# 2.route53にサブドメインのCNAMEを作成したクラウドフロントで作成する
# 3.cloudfrontにaliasを設定する

data "aws_route53_zone" "hostzone" {
  name = var.domain_name
}

resource "aws_route53_record" "sub_domain" {
  zone_id = data.aws_route53_zone.hostzone.zone_id
  name    = "${terraform.workspace}.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.main.domain_name]
}