#!/bin/bash

if [ $# -ne 3 ]; then
    echo "3 arguments are required: dir malicious_dir interval"
    exit 1
fi

dir="$1"
malicious_dir="$2"
interval="$3"

Extensions="exe bat vbs scr ps1"
Keywords="virus|trojan|malware|worm|ransomware"

mkdir -p "$malicious_dir"

is_malicious() {
    file="$1"
    for ext in $Extensions; do
        if [[ "$file" == *.$ext ]]; then
            return 0
        fi
    done

    for word in $Keywords; do
        if grep -qEia "$word" "$file"; then
            return 0
        fi
    done

    return 1 
}

scan() {
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            grep -qxF "$(basename "$file")" whitelist.txt 2>/dev/null && continue
            if is_malicious "$file"; then
                name=$(basename "$file")
                echo "$name is malicious and it is DELETED"
                cp "$file" "$malicious_dir/$name"
                rm "$file"
            fi
        fi
    done
}

if [ ! -f directory-info.last ]; then
    scan
    ls -l "$dir" > directory-info.last
fi

while true; do
    sleep "$interval"
    ls -l "$dir" > directory-info.new

    if ! cmp -s directory-info.last directory-info.new; then
        echo "Directory contents changed. Scanning for malicious files..."
        scan
        cp directory-info.new directory-info.last
    fi
done