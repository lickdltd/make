AWS_ACCOUNT_ID ?= 843827012977
AWS_REGION ?= eu-west-1

AWS_ECR_DOMAIN ?= $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

aws_ecr_login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ECR_DOMAIN)
