#!/bin/bash

Screenshot_Enum() {

    echo "Starting Web Screenshot Enumeration for $domain_name..."

    ############################################################
    # INPUT
    ############################################################

    input_file="$REPORT_DIR/httpx_live_subdomains.txt"

    if [[ ! -s "$input_file" ]]; then
        echo "[ERROR] Input file is empty or does not exist:"
        echo "        $input_file"
        return 1
    fi


    ############################################################
    # OUTPUT DIRECTORIES
    ############################################################

    SCREENSHOT_DIR="$REPORT_DIR/Screenshots"

    GOWITNESS_DIR="$SCREENSHOT_DIR/Gowitness"
    EYEWITNESS_DIR="$SCREENSHOT_DIR/EyeWitness"

    mkdir -p \
        "$GOWITNESS_DIR" \
        "$EYEWITNESS_DIR"


    ############################################################
    # GOWITNESS
    ############################################################

    echo
    echo "=========================================="
    echo "[+] Running Gowitness"
    echo "=========================================="

    if command -v gowitness >/dev/null 2>&1; then

        gowitness scan file \
            -f "$input_file" \
            --screenshot-path "$GOWITNESS_DIR"

        if [[ $? -eq 0 ]]; then
            echo "[✓] Gowitness completed"
        else
            echo "[ERROR] Gowitness failed"
        fi

    else

        echo "[ERROR] Gowitness is not installed."
        echo "[INFO] Install Gowitness before running this module."

    fi


    ############################################################
    # EYEWITNESS
    ############################################################

    echo
    echo "=========================================="
    echo "[+] Running EyeWitness"
    echo "=========================================="

    if command -v eyewitness >/dev/null 2>&1; then

        eyewitness \
            --web \
            -f "$input_file" \
            --no-prompt \
            --timeout 10 \
            --threads 10 \
            -d "$EYEWITNESS_DIR"

        if [[ $? -eq 0 ]]; then
            echo "[✓] EyeWitness completed"
        else
            echo "[ERROR] EyeWitness failed"
        fi

    else

        echo "[ERROR] EyeWitness is not installed."
        echo "[INFO] Install EyeWitness before running this module."

    fi


    ############################################################
    # SUMMARY
    ############################################################

    echo
    echo "=========================================="
    echo "[✓] Screenshot Enumeration Completed"
    echo "=========================================="

    echo
    echo "Input:"
    echo "    $input_file"

    echo
    echo "Gowitness:"
    echo "    $GOWITNESS_DIR"

    echo
    echo "EyeWitness:"
    echo "    $EYEWITNESS_DIR"

    echo
}