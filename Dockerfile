ARG PYTHON_VERSION=3.9
ARG ALPINE_VERSION=3.12
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

ARG AWSCLI_VERSION=1.19.*
RUN apk add --no-cache \
    groff \
    tini=~0.19 \
    && pip install --no-cache-dir awscli==${AWSCLI_VERSION}

ARG AWS_USER=aws
ARG AWS_GROUP=aws
ARG AWS_UID=1000
ARG AWS_GID=1000

RUN addgroup -g ${AWS_GID} ${AWS_GROUP} && \
    adduser -u ${AWS_UID} --disabled-password ${AWS_USER} -G ${AWS_GROUP} && \
    mkdir -p /home/${AWS_USER}/work && \
    chown -R ${AWS_USER}:${AWS_GROUP} /home/${AWS_USER}

USER ${AWS_USER}
WORKDIR /home/${AWS_USER}/work

# Wait for CMD to exit, reap zombies and perform signal forwarding
ENTRYPOINT ["/sbin/tini", "--", "aws"]
CMD ["help"]
