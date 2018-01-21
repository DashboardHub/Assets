.DEFAULT_GOAL := help

help:
	@echo 'Please read the documentation in "https://github.com/DashboardHub/Assets"'

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* is not set"; \
		exit 1; \
	fi

deploy: pipeline.version.deploy.start sync pipeline.version.deploy.finish

sync: guard-AWS_CLOUDFRONT_ID
	aws s3 sync _site s3://dashboardhub.io --delete --region eu-west-2
	aws cloudfront create-invalidation --distribution-id ${AWS_CLOUDFRONT_ID} --paths /\*

pipeline.version.deploy.start:
	curl -XPOST -H "Content-Type: application/json" -d '{"release":"0.1.${TRAVIS_BUILD_NUMBER}"}' https://api-pipeline.dashboardhub.io/environments/e4ee46c0-fe4c-11e7-b4bd-35d420cf5b7e/deployed/${DH_TOKEN}/startDeploy

pipeline.version.deploy.finish:
	curl -XPOST -H "Content-Type: application/json" -d '{"release":"0.1.${TRAVIS_BUILD_NUMBER}"}' https://api-pipeline.dashboardhub.io/environments/e4ee46c0-fe4c-11e7-b4bd-35d420cf5b7e/deployed/${DH_TOKEN}/finishDeploy
