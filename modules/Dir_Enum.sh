#!/bin/bash

Dir_Enum() {

    input_file="$REPORT_DIR/httpx_live_subdomains.txt"

    if [[ ! -s "$input_file" ]]; then
        echo "[ERROR] Live subdomains file not found."
        return 1
    fi

    DIRSEARCH_DIR="$REPORT_DIR/Dirsearch"
    FFUF_DIR="$REPORT_DIR/FFUF"

    mkdir -p "$DIRSEARCH_DIR" "$FFUF_DIR"

    DIR_WORDLIST="/usr/share/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt"
    FILE_WORDLIST="/usr/share/seclists/Discovery/Web-Content/common.txt"
    BACKUP_WORDLIST="/usr/share/seclists/Discovery/Web-Content/raft-large-files.txt"
    API_WORDLIST="/usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt"

    STATUS_CODES="200,201,202,204,301,302,307,308,400,401,403,405,409,410,415,422,429,500,501,502,503,504"

    ############################################################
    # DIRSEARCH
    ############################################################

    echo
    echo "=========================================="
    echo "Starting Dirsearch Enumeration"
    echo "=========================================="

    while IFS= read -r url
    do
        [[ -z "$url" ]] && continue

        host=$(echo "$url" | sed -E 's|https?://||; s|/.*||')

        echo
        echo "[*] Target : $url"

        dirsearch \
            -u "$url" \
            -e "*" \
            -t 50 \
            --random-agent \
            -o "$DIRSEARCH_DIR/${host}.txt"

    done < "$input_file"

    ############################################################
    # FFUF
    ############################################################

    echo
    echo "=========================================="
    echo "Starting FFUF Enumeration"
    echo "=========================================="

    while IFS= read -r url
    do
        [[ -z "$url" ]] && continue

        HOST=$(echo "$url" | sed -E 's|https?://||; s|/$||')

        HOST_DIR="$FFUF_DIR/$HOST"

        mkdir -p "$HOST_DIR"

        echo
        echo "[*] Target : $url"

        ###############################################
        # Directories
        ###############################################

        echo "[+] Directory Enumeration"

        ffuf \
            -u "$url/FUZZ" \
            -w "$DIR_WORDLIST" \
            -mc "$STATUS_CODES" \
            -fc 404 \
            -t 50 \
            -of json \
            -o "$HOST_DIR/directories.json"

        ###############################################
        # Files
        ###############################################

        echo "[+] File Enumeration"

        ffuf \
            -u "$url/FUZZ" \
            -w "$FILE_WORDLIST" \
            -e php,txt,bak,zip,tar,gz,sql,env,conf,config,old,log \
            -mc "$STATUS_CODES" \
            -fc 404 \
            -t 50 \
            -of json \
            -o "$HOST_DIR/files.json"

        ###############################################
        # Backup Files
        ###############################################

        echo "[+] Backup File Discovery"

        ffuf \
            -u "$url/FUZZ" \
            -w "$BACKUP_WORDLIST" \
            -e bak,old,zip,tar,gz,7z,rar \
            -mc "$STATUS_CODES" \
            -fc 404 \
            -t 50 \
            -of json \
            -o "$HOST_DIR/backups.json"

        ###############################################
        # API Discovery
        ###############################################

        if [[ -f "$API_WORDLIST" ]]; then

            echo "[+] API Endpoint Discovery"

            ffuf \
                -u "$url/FUZZ" \
                -w "$API_WORDLIST" \
                -mc "$STATUS_CODES" \
                -fc 404 \
                -t 50 \
                -of json \
                -o "$HOST_DIR/api.json"

        else
            echo "[!] API wordlist not found. Skipping..."
        fi

        ###############################################
        # GraphQL
        ###############################################

        echo "[+] GraphQL Discovery"

        ffuf \
            -u "$url/FUZZ" \
            -w <(printf "graphql\ngraphql/\ngraphiql\napi/graphql\nv1/graphql\n") \
            -mc "$STATUS_CODES" \
            -fc 404 \
            -t 50 \
            -of json \
            -o "$HOST_DIR/graphql.json"

        ###############################################
        # Extensions
        ###############################################

        echo "[+] Extension Discovery"

        ffuf \
            -u "$url/index.FUZZ" \
            -w <(printf "php\nasp\naspx\njsp\nhtml\njs\njson\nxml\nbak\nold\nzip\n") \
            -mc "$STATUS_CODES" \
            -fc 404 \
            -t 50 \
            -of json \
            -o "$HOST_DIR/extensions.json"

        echo "[✓] Completed : $HOST"

    done < "$input_file"

    echo
    echo "=========================================="
    echo "Directory Enumeration Completed"
    echo "=========================================="
    echo
    echo "Dirsearch Results : $DIRSEARCH_DIR"
    echo "FFUF Results      : $FFUF_DIR"
    echo
}