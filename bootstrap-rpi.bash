#! /usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: bootstrap-rpi.bash <path>"
    echo
    echo "The <path> argument should be the path to the Raspberry Pi boot filesystem,"
    echo "with the SD card mounted on your computer."
    exit 1
fi


target_dir="$1"

if [ ! -d "${target_dir}" ]; then
    echo "Given target is not a valid directory."
    exit 1
fi


echo "Please enter a password for user '${USER}'."
password=$(openssl passwd -6)

if [ -z "${password}" ]; then
    echo "Failed to generate password hash. Aborting."
    exit 1
fi


echo "Populating 'userconf.txt' file to create user '${USER}'..."
cat > "${target_dir}/userconf.txt" << EOF
${USER}:${password}
EOF


echo "Creating empty 'ssh' file to enable SSH server..."
touch "${target_dir}/ssh"
