#!/bin/bash

Vuln_Scan() {

    echo
    echo "=========================================="
    echo "[*] Running : Vulnerability Scanning"
    echo "=========================================="

    ############################################################
    # INPUT
    ############################################################

    input_file="$REPORT_DIR/httpx_live_subdomains.txt"

    if [[ ! -s "$input_file" ]]; then
        echo "[ERROR] Live subdomains file not found:"
        echo "        $input_file"
        return 1
    fi


    ############################################################
    # OUTPUT DIRECTORIES
    ############################################################

    VULN_DIR="$REPORT_DIR/Vuln_Scan"

    NUCLEI_DIR="$VULN_DIR/Nuclei"
    NIKTO_DIR="$VULN_DIR/Nikto"

    mkdir -p "$NUCLEI_DIR" "$NIKTO_DIR"


    ############################################################
    # NUCLEI
    ############################################################

    echo
    echo "=========================================="
    echo "[+] Starting Nuclei"
    echo "=========================================="

    if command -v nuclei >/dev/null 2>&1; then

        NUCLEI_OUTPUT="$NUCLEI_DIR/nuclei_results.txt"

        nuclei \
            -l "$input_file" \
            -severity info,low,medium,high,critical \
            -etags dos,fuzz \
            -rate-limit 50 \
            -bulk-size 25 \
            -concurrency 10 \
            -timeout 10 \
            -retries 2 \
            -stats \
            -o "$NUCLEI_OUTPUT"

        if [[ $? -eq 0 ]]; then
            echo "[✓] Nuclei scanning completed."
            echo "[+] Results:"
            echo "    $NUCLEI_OUTPUT"
        else
            echo "[!] Nuclei completed with errors."
        fi

    else

        echo "[ERROR] nuclei is not installed."
        echo "[INFO] Skipping Nuclei."

    fi


    ############################################################
    # NIKTO
    ############################################################

    echo
    echo "=========================================="
    echo "[+] Starting Nikto"
    echo "=========================================="

    if command -v nikto >/dev/null 2>&1; then

        while IFS= read -r url
        do

            [[ -z "$url" ]] && continue

            HOST=$(echo "$url" | sed -E 's|https?://||; s|/.*||')

            echo
            echo "[+] Nikto Target : $url"

            nikto \
                -h "$url" \
                -output "$NIKTO_DIR/${HOST}.txt" \
                -Format txt \
                -Tuning 12345789 \
                -timeout 10

            if [[ $? -eq 0 ]]; then
                echo "[✓] Nikto completed : $HOST"
            else
                echo "[!] Nikto encountered an error : $HOST"
            fi

        done < "$input_file"

    else

        echo "[ERROR] nikto is not installed."
        echo "[INFO] Skipping Nikto."

    fi


    ############################################################
    # SUMMARY
    ############################################################

    echo
    echo "=========================================="
    echo "[✓] Vulnerability Scanning Completed"
    echo "=========================================="

    echo
    echo "Nuclei results:"
    echo "    $NUCLEI_DIR"

    echo
    echo "Nikto results:"
    echo "    $NIKTO_DIR"

    echo
}