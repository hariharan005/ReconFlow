#!/bin/bash

############################################################
# HTTPX RECON
############################################################

httpx_recon() {

    ########################################################
    # INPUT
    ########################################################

    input_file="$REPORT_DIR/Subdomains.txt"

    if [[ ! -s "$input_file" ]]; then

        echo "[ERROR] Subdomains.txt is empty or does not exist."
        echo "[INFO] Please run subdomain reconnaissance first."

        return 1

    fi


    ########################################################
    # HTTPX BINARY
    ########################################################

    HTTPX_BIN="$HOME/go/bin/httpx"

    if [[ ! -x "$HTTPX_BIN" ]]; then

        echo "[ERROR] ProjectDiscovery httpx not found:"
        echo "        $HTTPX_BIN"

        echo
        echo "[INFO] Check with:"
        echo "        which httpx"

        return 1

    fi


    ########################################################
    # OUTPUT FILES
    ########################################################

    output_file="$REPORT_DIR/httpx_results.txt"

    output_file_live_subdomains="$REPORT_DIR/httpx_live_subdomains.txt"


    ########################################################
    # CREATE REPORT DIRECTORY
    ########################################################

    mkdir -p "$REPORT_DIR"


    ########################################################
    # START
    ########################################################

    echo
    echo "=========================================="
    echo "[*] Running : HTTPX Recon"
    echo "=========================================="
    echo

    echo "[+] Input       : $input_file"
    echo "[+] HTTPX       : $HTTPX_BIN"
    echo "[+] Output      : $output_file"
    echo "[+] Live Hosts  : $output_file_live_subdomains"
    echo


    ########################################################
    # RUN HTTPX
    ########################################################

    echo "[+] Starting HTTPX reconnaissance..."

    "$HTTPX_BIN" \
        -l "$input_file" \
        -follow-redirects \
        -tech-detect \
        -status-code \
        -title \
        -server \
        -ip \
        -silent \
        -o "$output_file"


    ########################################################
    # CHECK HTTPX EXIT STATUS
    ########################################################

    if [[ $? -ne 0 ]]; then

        echo
        echo "[ERROR] HTTPX reconnaissance failed."

        return 1

    fi


    ########################################################
    # CHECK OUTPUT
    ########################################################

    if [[ ! -s "$output_file" ]]; then

        echo
        echo "[ERROR] HTTPX produced no output."

        return 1

    fi


    echo
    echo "[✓] HTTPX reconnaissance completed."
    echo "[+] Results saved to:"
    echo "    $output_file"


    ########################################################
    # EXTRACT LIVE SUBDOMAINS
    ########################################################

    echo
    echo "[+] Extracting live subdomains..."


    awk '
    {
        print $1
    }
    ' "$output_file" \
    | sed -E 's|https?://||; s|/.*||' \
    | sort -u \
    > "$output_file_live_subdomains"


    ########################################################
    # CHECK LIVE RESULTS
    ########################################################

    if [[ ! -s "$output_file_live_subdomains" ]]; then

        echo
        echo "[WARNING] No live subdomains were extracted."

    else

        LIVE_COUNT=$(wc -l < "$output_file_live_subdomains")

        echo
        echo "[✓] Live subdomains found : $LIVE_COUNT"

        echo
        echo "[+] Live subdomains saved to:"
        echo "    $output_file_live_subdomains"

    fi


    ########################################################
    # COMPLETED
    ########################################################

    echo
    echo "=========================================="
    echo "[✓] HTTPX Recon Completed"
    echo "=========================================="
    echo

    return 0
}