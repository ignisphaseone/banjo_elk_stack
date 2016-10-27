#!/bin/bash
if [[ ! $EUID -eq 0 ]]; then
    echo "--this script requires root beer (sudo), exiting..."
fi

USERNAME="banjodemo"
HTPWFILE="/etc/nginx/htpasswd.users"
echo "--creating new user '$USERNAME' in '$HTPWFILE'..."
echo "$USERNAME:`openssl passwd -apr1`" | tee -a "$HTPWFILE"
