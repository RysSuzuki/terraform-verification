variable "name" {}
variable "policy" {}
variable "identifier" {}

# ロールを作成している（作成と同時に”信頼関係”の設定をしている）
resource "aws_iam_role" "default" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# ポリシーのアクセス権限設定を構成している（jsonのもの）
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [var.identifier]
    }
  }
}

# ポリシー設定をしている
resource "aws_iam_policy" "default" {
  name   = var.name
  policy = var.policy
}

# 作成したロールにポリシーをアタッチしている
resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

# 外部参照できるようにしている
output "iam_role_arn" {
  value = aws_iam_role.default.arn
}
output "iam_role_name" {
  value = aws_iam_role.default.name
}

# 複数のロールをアタッチする方法サンプル
# resource "aws_iam_role_policy_attachment" "default" {
#   for_each = toset([
#     "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
#     "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#   ])
#   role       = aws_iam_role.default.name
#   policy_arn = each.value
# }
