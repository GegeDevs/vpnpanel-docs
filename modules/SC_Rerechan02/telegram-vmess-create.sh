#!/usr/bin/env bash

# Mengambil input dari argumen baris perintah
USERNAME="$1"
PASSWORD="$2"
EXPIRED="$3"

# Variabel yang sudah ditentukan (hardcoded) untuk menjawab prompt
limitip="3"
limitquota="100"
uuid="2"

# Validasi untuk memastikan semua argumen yang diperlukan telah diberikan
if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$EXPIRED" ]]; then
    echo "Penggunaan: $0 <username> <password> <masa_aktif_hari>"
    echo "Contoh: $0 'user_test' 'pass123' '30'"
    exit 1
fi

# Blok expect untuk otomatisasi, dengan output yang difilter oleh sed dan awk
expect <<EOF | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '/╔/,/╝/'
# Set timeout dan variabel lingkungan
set timeout 10
set env(TERM) xterm

# Salin variabel bash ke dalam variabel expect
set username "$USERNAME"
set password "$PASSWORD"
set expired "$EXPIRED"
set limitip "$limitip"
set limitquota "$limitquota"
set uuid "$uuid"

# Jalankan skrip add-vmess
spawn add-vmess

# 1. Menunggu prompt "Email" dan mengirimkan username
expect {
    -re "(?i)Email.*:.*" { send -- "\$username\r" }
    timeout { puts "Error: Timeout saat menunggu prompt Email."; exit 1 }
}

# 2. Menunggu prompt "Quota (GB)" dan mengirimkan limit kuota
expect {
    -re "(?i)Quota.*GB.*:.*" { send -- "\$limitquota\r" }
    timeout { puts "Error: Timeout saat menunggu prompt Kuota."; exit 1 }
}

# 3. Menunggu prompt "Max IP login" dan mengirimkan limit IP
expect {
    -re "(?i)Max IP login.*:.*" { send -- "\$limitip\r" }
    timeout { puts "Error: Timeout saat menunggu prompt Limit IP."; exit 1 }
}

# 4. Menunggu prompt "Expired" dan mengirimkan masa aktif
expect {
    -re "(?i)Expired.*:.*" { send -- "\$expired\r" }
    timeout { puts "Error: Timeout saat menunggu prompt Expired."; exit 1 }
}

# 5. Menunggu prompt "Input UUID (Empty Default)" dan mengirimkan password dari argumen
expect {
    -re "(?i)Input UUID.*:.*" { send -- "\$uuid\r" }
    timeout { puts "Error: Timeout saat menunggu prompt Password."; exit 1 }
}

# Tunggu hingga proses add-vmess selesai
expect eof
EOF
