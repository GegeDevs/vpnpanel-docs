#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"

limitip="3"

if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$EXPIRED" ]]; then
    echo "Usage: $0 <username> <password> <expired_days>"
    exit 1
fi

expect <<EOF | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '/╔/,/╝/'
set timeout 10
set env(TERM) xterm

set username "$USERNAME"
set password "$PASSWORD"
set expired "$EXPIRED"
set limitip "$limitip"

spawn add-ssh

# Masukkan username
expect {
    -re "(?i)Username.*:.*" { send "\$username\r" }
    timeout { send "\$username\r" }
}

# Masukkan password
expect {
    -re "(?i)Password.*:.*" { send "\$password\r" }
    timeout { send "\$password\r" }
}

# Limit IP kosong
expect {
    -re "(?i)Limit IP.*:.*" { send "\$limitip\r" }
    timeout { send "\$limitip\r" }
}

# Masukkan expired
expect {
    -re "(?i)Expired.*:.*" { send "\$expired\r" }
    timeout { send "\$expired\r" }
}

expect eof
EOF