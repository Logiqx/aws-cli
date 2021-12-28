# AWS CLI for Docker

The AWS Command Line Interface (CLI) is a unified tool to manage your AWS services.

This image has been created to satisfy the following requirements:

- Use official Python base images - Alpine and Debian (slim)
- Use specific release of the AWS CLI
- Avoid running as the root user



### Usage

When a container is run without arguments the AWS CLI help page will be displayed:

```
docker container run -it --rm logiqx/aws-cli
```

Since the ENTRYPOINT is the "aws" command a container must be run as follows:

```
docker container run -it --rm logiqx/aws-cli [options] <command> <subcommand> [<subcommand> ...] [parameters]
```

Note: The "aws" portion of the command is not required because it is specified in the ENTRYPOINT.



#### Using the Debian Image

The Debian image is used in much the same way as the Alpine image by specifying the appropriate tag:

```
docker container run -it --rm logiqx/aws-cli:slim
```



### AWS Credentials

Almost all AWS CLI commands require credentials and there are several options to consider.

#### Environment Variables

You can specify the environment variables `$AWS_ACCESS_KEY_ID` and `$AWS_SECRET_ACCESS_KEY` when starting the container but this is **not** encouraged because it is asking for trouble!

There is little benefit in specifying `$AWS_DEFAULT_REGION` since the region can simply be specified on the command line.

```
docker container run -it --rm logiqx/aws-cli ec2 start-instances \
       --region us-east-1 --instance-ids ...
```

#### $HOME/.aws

Bind mounting `$HOME/.aws` from the host into the container is a reasonable approach to consider:

```
docker container run -it --rm -v $HOME/.aws:/home/aws/.aws logiqx/aws-cli ...
```

This approach will make `$HOME/.aws/config` and `$HOME/.aws/credentials` of the host accessible to the AWS CLI running inside the container.

Note: Mounting `$HOME/.aws` will almost certainly require the UID of the "aws" user to match the UID of the directories and files on the host. You may need to build a custom image to get this approach working!

#### IAM Role(s)

IAM role(s) assigned to the host are another reasonable approach and may be the most secure option.

Suitable AWS credentials can be granted to the host / revoked from the host centrally via the AWS console.

The IAM approach does not require any secrets / credentials to be stored on the host machine.



### Building a Custom Image

To build a custom image for a specific version of the AWS CLI, Python or Alpine use the following syntax:

```
docker image build --build-arg AWSCLI_VERSION=1.22.* . -t aws-cli:1.22-alpine3.15
```

To build a custom Debian image simply use Dockerfile-slim instead of Dockerfile:

```
docker image build --file Dockerfile-slim --build-arg AWSCLI_VERSION=1.22.* . -t aws-cli:1.22-slim-bullseye
```

You can provide overrides for the following:

- AWSCLI_VERSION - default of 1.22.*
- PYTHON_VERSION - default of 3.10
- ALPINE_VERSION / DEBIAN_VERSION  - default of 3.15 / bullseye
- AWS_USER and AWS_GROUP - default of aws
- AWS_UID and AWS_GID - default of 1000
