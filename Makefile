.PHONY: build run test

##
# Makefile used to build, test and (locally) run the packagewith.me project.
##

##
# ENVRONMENT VARIABLES
#   We use a number of environment  variables to customer the Docker image createad at build time. These are set and
#   detailed below.
##

# App name used to created our Docker image. This name is important in the context of the AWS docker repository.
APP_NAME = packagewith.me

# AWS account ID used to create our Docker image. This value is important in the context of the AWS docker repository.
# When executed in GoCD, AWS_ACCOUNT_ID may be set by an environment variable
AWS_ACCOUNT_ID ?= $(or $(shell aws sts get-caller-identity --output text --query "Account" 2 > /dev/null), unknown)

# Which Rack environment will our docker image be configured to run in?
RACK_ENV ?= development

# The name of our Docker image
IMAGE = $(AWS_ACCOUNT_ID).dkr.ecr.eu-west-1.amazonaws.com/$(APP_NAME)

# Container port used for mapping when running our Docker image.
CONTAINER_PORT = 3000

# Host port used for mapping when running our Docker image.
HOST_PORT = 80

##
# MAKE TASKS
#   Tasks used locally and within our build pipelines to build, test and run our Docker image.
##

build: # Using the variables defined above, run `docker build`, tagging the image and passing in the required arguments.
	docker build -t $(IMAGE):latest \
		--build-arg ETSY_API_KEY=$(ETSY_API_KEY) \
		--build-arg ETSY_API_SECRET=$(ETSY_API_SECRET) \
		--build-arg SECRET_KEY_BASE=$(SECRET_KEY_BASE) \
		--build-arg AIRBRAKE_PROJECT_ID=$(AIRBRAKE_PROJECT_ID) \
		--build-arg AIRBRAKE_PROJECT_KEY=$(AIRBRAKE_PROJECT_KEY) \
		--build-arg RACK_ENV=$(RACK_ENV) \
		.

run: # Run the Docker image we have created, mapping the HOST_PORT and CONTAINER_PORT
	docker run --rm -p $(HOST_PORT):$(CONTAINER_PORT) $(IMAGE)

test: # Build the docker image in development mode, using a test PARLIAMENT_BASE_URL. Then run rake within a Docker container using our image.
	RACK_ENV=development make build
	docker run --rm $(IMAGE):latest bundle exec rake