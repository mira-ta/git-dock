# alpine 3.12.0 supports several architectures including
#     i386 amd64 armv6 armv7
#     arm64v8 arm64v8 ppv64le s390x
# see https://hub.docker.com/_/alpine?tab=tags
FROM alpine:3.12.0

ARG GIT_USER_HOME="/home/git"
ARG GIT_USER_NAME="git"
ARG GIT_REPOSITORIES_DIRECTORY="repos"

RUN apk add --no-cache --verbose \
        openssh-server openssh-server-common git

ADD --chown=root:root ssh/* /etc/ssh/

# Generate hostkeys after adding the contents of
# repository's ssh/ directory to prevent using 
# predefined hostkeys.
RUN ssh-keygen -A

RUN adduser -D -h "${GIT_USER_HOME}" -s /usr/bin/git-shell "${GIT_USER_NAME}" && \
        { echo "${GIT_USER_NAME}:${GIT_USER_NAME}" | chpasswd; } && \
        echo "${GIT_USER_HOME}" > /var/run/git_user_home && \
        echo "${GIT_USER_NAME}" > /var/run/git_user_name && \
        echo "${GIT_REPOSITORIES_DIRECTORY}" > /var/run/git_repositories_directory && \
        mkdir --mode 700 "${GIT_USER_HOME}"/.ssh && \
        install -m 600 /dev/null "${GIT_USER_HOME}"/.ssh/authorized_keys && \
        chown -R "${GIT_USER_NAME}":"${GIT_USER_NAME}" "${GIT_USER_HOME}"/.ssh/

# Add files from `home` directory in this repository to
# current home directory of git user.
# ADD --chown="${GIT_USER_NAME}":"${GIT_USER_NAME}" home/* "${GIT_USER_HOME}"/

RUN mkdir --mode 750 "${GIT_USER_HOME}"/.git-repositories/ && \
        ln -s "${GIT_USER_HOME}"/.git-repositories/ "${GIT_USER_HOME}"/repository && \
        ln -s "${GIT_USER_HOME}"/.git-repositories/ "${GIT_USER_HOME}"/repos && \
        ln -s "${GIT_USER_HOME}"/.git-repositories/ "${GIT_USER_HOME}"/r

VOLUME "${GIT_USER_HOME}"/.git-repositories/

EXPOSE 22

ADD --chown=root:root sshdi /usr/bin/sshdi

ENTRYPOINT ["/usr/bin/sshdi"]

