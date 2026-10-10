#!/bin/bash

if [ $# -ne 2 ]; then   
    echo "2 arguments are required: dir malicious_dir"
    exit 1
fi

dir="$1"
malicious_dir="$2"

if [ -z "$(ls -A "$malicious_dir" 2>/dev/null)" ]; then
    echo "No malicious files to review"  
    exit 0
fi

while true; do
    files=()
    for f in "$malicious_dir"/*; do
        [ -f "$f" ] && files+=("$(basename "$f")")
    done

    if [ ${#files[@]} -eq 0 ]; then
        echo "No more files to review"
        break
    fi

    echo "Quarantined files:"
    for i in "${!files[@]}"; do
        echo "$((i + 1)). ${files[$i]}"
    done

    read -p "Enter the number of the file to review (0 to quit): " num || break
    [ "$num" = "0" ] && break
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#files[@]}" ]; then
        echo "Invalid selection. Please try again."
        continue
    fi

    file="${files[$((num - 1))]}"
    echo "1) Restore $file to $dir"
    echo "2) Permanently delete $file"
    echo "3) Leave $file as it is"
    read -p "Choose an option (1-3): " choice || break

    case "$choice" in
        1)
            mv "$malicious_dir/$file" "$dir/"
            echo "$file" >> whitelist.txt
            echo "Restored $file to $dir"
            ;;
        2)
            rm "$malicious_dir/$file"
            echo "$file permanently deleted"
            ;;
        3)
            echo "$file remains in quarantine"
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
