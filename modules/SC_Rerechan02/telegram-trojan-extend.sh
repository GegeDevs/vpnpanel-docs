#!/usr/bin/env bash

USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"

limitip="3"
limitquota="100"

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
set limitquota "$limitquota"

spawn renew-trojan

# 1. Menunggu prompt Username dan mengirimkan isinya
expect {
    -re "(?i)Input Username.*:" {
        send "\$username\r"
    }
    timeout {
        puts "Error: Tidak menemukan prompt Username dalam 15 detik."
        exit 1
    }
}

# 2. Menunggu prompt 'custom expired' dan mengirimkan enter (pilih 'N')
expect {
    -re "(?i)Gunakan custom expired?.*:" {
        send "\r"
    }
    timeout {
        puts "Error: Tidak menemukan prompt 'custom expired' dalam 15 detik."
        exit 1
    }
}

# 3. Menunggu prompt 'Input Extend' dan mengirimkan jumlah hari
expect {
    -re "(?i)Input Extend.*:" {
        send "\$expired\r"
    }
    timeout {
        puts "Error: Tidak menemukan prompt 'Input Extend' dalam 15 detik."
        exit 1
    }
}
expect eof
EOF
