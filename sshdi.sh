#!/bin/sh
# Script for interactive configuring sshd server
# in docker container.

SSHD_COMMAND="/usr/sbin/sshd"
SSH_SYSTEM_CONFIGURATION_DIRECTORY="/etc/ssh"
SSH_USER_CONFIGURATION_DIRECTORY="`cat /var/run/git_user_home`/.ssh"


_assure_input() {
    echo -n "Are you sure? (y/N): " >&2

    local REPLY
    read REPLY

    if echo "${REPLY}" | grep -v -q "[Yy]"; then
        echo "Aborted." >&2
        return 1
    else
        return 0
    fi
}


_echo_allowed_pubkey_formats() {
    cat << EOF
ssh-ed25519
ssh-ed25519-cert-v01
sk-ssh-ed25519
sk-ssh-ed25519-cert-v01
ssh-rsa
ssh-dss
ecdsa-sha2-nistp256
ecdsa-sha2-nistp384
ecdsa-sha2-nistp521
sk-ecdsa-sha2-nistp256
ssh-rsa-cert-v01
ssh-dss-cert-v01
ecdsa-sha2-nistp256-cert-v01
ecdsa-sha2-nistp384-cert-v01
ecdsa-sha2-nistp521-cert-v01
sk-ecdsa-sha2-nistp256-cert-v01
EOF
}


keys() {
    case "$1" in 
        add)
            shift

            echo -n "Please, enter the public key (in one line): " >&2

            local PUBKEY
            read PUBKEY
            
            local PUBKEY_FORMAT="$(echo "${PUBKEY}" | cut -d\  -f1)"

            if ! _assure_input; then
                return
            fi

            if ! _echo_allowed_pubkey_formats | grep -q -F "${PUBKEY_FORMAT}"; then
                echo "Key format ${PUBKEY_FORMAT} is disallowed or not supported." >&2
            else
                echo "${PUBKEY}" >> "${SSH_USER_CONFIGURATION_DIRECTORY}"/authorized_keys
                echo "Key has been added to \`"${SSH_USER_CONFIGURATION_DIRECTORY}"/authorized_keys\`." >&2
            fi
            ;;
        remove)
            shift

            echo -n "Please, enter the public key/regular expression (in one line):" >&2

            local FORMAT
            read FORMAT

            if ! _assure_input; then
                return
            fi

            sed -i -E "/${FORMAT}/d" "${SSH_USER_CONFIGURATION_DIRECTORY}"/authorized_keys
            ;;
        list)
            shift

            cat "${SSH_USER_CONFIGURATION_DIRECTORY}"/authorized_keys >&2
            ;;
        *)
            echo "Invalid argument. Use \`add\`, \`remove\` or \`list\`." >&2
            ;;
    esac
}


run() {
    echo "Executing sshd server (not recommended if you are in \`attached\` mode," >&2
    echo "a.k.a --interactive --tty flags are provided to docker run)." >&2

    exec "${SSHD_COMMAND}" -D "$@"
}


main() {
    echo "Welcome to configure script!" >&2
    echo "Type \`keys\` to see little help about keys manipulating." >&2
    echo "Type \`run\` to exec server." >&2

    while read; do
        eval "${REPLY}"
    done
}

# check is everything ok
if [ "${*}" == "run" ]; then
    run
fi

# run the entrypoint main function with provided
# arguments
main "${@}"

