#!/bin/bash

cd "$(dirname "$0")"

dir="test_dir"
malicious_dir="malicious_dir"

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

scan