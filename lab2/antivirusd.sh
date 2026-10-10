#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 dir malicious_dir interval-secs"
    exit 1
fi

dir="$1"
malicious_dir="$2"
interval="$3"

EXTENSIONS="exe bat vbs scr ps1"
KEYWORDS="virus|trojan|malware|worm|ransomware"

mkdir -p "$malicious_dir"

is_malicious() {
    local file="$1"
    local name
    name=$(basename "$file")

    if [[ "$name" == *.* ]]; then 
        local ext="${name##*.}"
        ext="${ext,,}"
        for bad in $EXTENSIONS; do
            if [[ "$ext" == "$bad" ]]; then
                return 0
            fi
        done
    fi

   if grep -qE "$KEYWORDS" "$file"; then
        return 0
    fi

    return 1 
}

scan() {
    for file in "$dir"/*; do
        [ -f "$file" ]  || continue
            if is_malicious "$file"; then
                name =$(basename "$file")
                echo "$name is malicious and is deleted"
                cp "$file" "$malicious_dir/$name"
                rm "$file"
            fi
    done
}

if [ ! -f directory-info.last ]; then
    scan
    ls -1 "$dir" > directory-info.last
fi

while true; do
    sleep "$interval"
    ls -1 "$dir" > directory-info.new

    if ! cmp -s directory-info.last directory-info.new; then
        echo "Directory contents changed. Scanning for malicious files..."
        scan
        cp directory-info.new directory-info.last
    fi
done