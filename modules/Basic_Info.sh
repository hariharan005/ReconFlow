#!/bin/bash

IP() {
    local host="$1"

    echo "IP Address:"
    nmap -sL -n "$host" | awk '/Nmap scan report for/{print "IP: "$NF}' | tr -d '()'
}

Dig() {
    local host="$1"

    echo
    echo "DNS Records:"
    echo

    for type in A AAAA MX NS TXT CNAME SOA
    do
        echo "=== $type ==="
        dig "$host" "$type" +short
        echo
    done
}

Basic_Info() {

    input_file="$REPORT_DIR/httpx_live_subdomains.txt"
    output_file="$REPORT_DIR/Basic_Info.txt"

    if [[ ! -f "$input_file" ]]; then
        echo "[ERROR] $input_file not found."
        return 1
    fi

    > "$output_file"

    while read -r host
    do
        [[ -z "$host" ]] && continue

        {
            echo "====================================================="
            echo "Host : $host"
            echo "====================================================="
            echo

            IP "$host"

            echo

            Dig "$host"

            echo
            echo
        } >> "$output_file"

    done < "$input_file"

    echo "Basic information saved to:"
    echo "$output_file"
}