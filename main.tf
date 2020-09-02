provider "aws" {
    region = var.aws_region
}

data "template_file" "deployer_policy_a" {
    template = file(abspath("${path.module}/iam-policy-a.json"))
    vars = {
      stage = var.stage
    }
}

data "template_file" "deployer_policy_b" {
    template = file(abspath("${path.module}/iam-policy-b.json"))
    vars = {
      stage = var.stage
    }
}

data "template_file" "deployer_policy_dev" {
  template = file(abspath("${path.module}/iam-policy-dev.json"))
    vars = {
      stage = var.stage
    }
}

resource "aws_iam_policy" "deployer_policy_a" {
    name = "deploy_policy_a"
    description = "Deployer policy part 1"
    policy = data.template_file.deployer_policy_a.rendered
}

resource "aws_iam_policy" "deployer_policy_b" {
    name = "deploy_policy_b"
    description = "Deployer policy part 2"
    policy = data.template_file.deployer_policy_b.rendered
}

resource "aws_iam_policy" "deployer_policy_dev" {
    count = var.dev ? 1 : 0
    name = "deploy_policy_dev"
    description = "Deployer policy dev rules"
    policy = data.template_file.deployer_policy_dev.rendered
}

resource "aws_iam_user" "restricted_deployer_user" {
  count = var.create_user ? 1 : 0
  name = "${var.stage}-restricted-deployer"
  force_destroy = true

  tags = {
    Name = "${var.stage}-restricted-deployer"
  }
}

resource "aws_iam_user_policy_attachment" "restricted_deployer_user_policy_a" {
  count = var.create_user ? 1 : 0
  user = aws_iam_user.restricted_deployer_user[0].name
  policy_arn = aws_iam_policy.deployer_policy_a.arn
}

resource "aws_iam_user_policy_attachment" "restricted_deployer_user_policy_b" {
  count = var.create_user ? 1 : 0
  user = aws_iam_user.restricted_deployer_user[0].name
  policy_arn = aws_iam_policy.deployer_policy_b.arn
}

resource "aws_iam_user_policy_attachment" "restricted_deployer_user_policy_dev" {
  count = var.dev && var.create_user ? 1 : 0
  user = aws_iam_user.restricted_deployer_user[0].name
  policy_arn = aws_iam_policy.deployer_policy_dev[0].arn
}

resource "aws_iam_access_key" "restricted_deployer_user_access_key" {
  count = var.create_user ? 1 : 0
  user    = aws_iam_user.restricted_deployer_user[0].name
}

output "AWS_ACCESS_KEY_ID" { value = var.create_user ? aws_iam_access_key.restricted_deployer_user_access_key[0].id : "" }
output "AWS_SECRET_ACCESS_KEY" { value = var.create_user ? aws_iam_access_key.restricted_deployer_user_access_key[0].secret : "" }
