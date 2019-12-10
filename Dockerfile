ARG PYTHON_VERSION=3.8
ARG ALPINE_VERSION=3.10

FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

ARG AWSCLI_VERSION=1.16.299

ARG AWS_USER=aws
ARG AWS_GROUP=aws
ARG AWS_UID=1000
ARG AWS_GID=1000

RUN apk add --no-cache groff tini=~0.18 && \
    pip install --no-cache-dir awscli==${AWSCLI_VERSION} && \
    addgroup -g ${AWS_GID} ${AWS_GROUP} && \
    adduser -u ${AWS_UID} --disabled-password ${AWS_USER} -G ${AWS_GROUP} && \
    mkdir /home/${AWS_USER}/work && \
    chown ${AWS_USER}:${AWS_GROUP} /home/${AWS_USER}/work

USER ${AWS_USER}
WORKDIR /home/${AWS_USER}/work

# Wait for CMD to exit, reap zombies and perform signal forwarding
ENTRYPOINT ["/sbin/tini", "--", "aws"]
CMD ["help"]
