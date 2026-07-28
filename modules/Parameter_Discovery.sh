Parameter_Discovery() {

    input_file="$REPORT_DIR/httpx_live_subdomains.txt"

    if [[ ! -s "$input_file" ]]; then
        echo "[ERROR] Live subdomains file not found."
        return 1
    fi

    PARAM_DIR="$REPORT_DIR/Parameter_Discovery"

    GAU_DIR="$PARAM_DIR/gau"
    WAYBACK_DIR="$PARAM_DIR/waybackurls"
    KATANA_DIR="$PARAM_DIR/katana"
    PARAMSPIDER_DIR="$PARAM_DIR/paramspider"
    ARJUN_DIR="$PARAM_DIR/arjun"

    mkdir -p \
        "$GAU_DIR" \
        "$WAYBACK_DIR" \
        "$KATANA_DIR" \
        "$PARAMSPIDER_DIR" \
        "$ARJUN_DIR"

    echo
    echo "=========================================="
    echo "Starting Parameter Discovery"
    echo "=========================================="

    while IFS= read -r url
    do
        [[ -z "$url" ]] && continue

        HOST=$(echo "$url" | sed -E 's|https?://||; s|/.*||')

        echo
        echo "[*] Target : $url"

        ###################################################
        # gau
        ###################################################

        echo "[+] Running gau"

        gau "$HOST" \
            > "$GAU_DIR/${HOST}.txt"

        ###################################################
        # waybackurls
        ###################################################

        echo "[+] Running waybackurls"

        echo "$HOST" | waybackurls \
            > "$WAYBACK_DIR/${HOST}.txt"

        ###################################################
        # katana
        ###################################################

        echo "[+] Running katana"

        katana \
            -u "$url" \
            -jc \
            -kf all \
            -d 5 \
            -silent \
            -o "$KATANA_DIR/${HOST}.txt"

        ###################################################
        # ParamSpider
        ###################################################

        echo "[+] Running ParamSpider"

        paramspider \
            -d "$HOST" \
            --exclude woff,css,svg,png,jpg,jpeg,gif,woff2 \
            --output "$PARAMSPIDER_DIR/${HOST}.txt"

        ###################################################
        # Arjun
        ###################################################

        echo "[+] Running Arjun"

        arjun \
            -u "$url" \
            -oT "$ARJUN_DIR/${HOST}.txt"

        echo "[✓] Completed : $HOST"

    done < "$input_file"

    ###################################################
    # Merge Results
    ###################################################

    echo
    echo "=========================================="
    echo "Merging Results"
    echo "=========================================="

    find "$PARAM_DIR" \
        -name "*.txt" \
        -exec cat {} + \
        | sort -u \
        > "$PARAM_DIR/all_parameter_urls.txt"

    grep "=" "$PARAM_DIR/all_parameter_urls.txt" \
        | sort -u \
        > "$PARAM_DIR/parameter_urls.txt"

    echo
    echo "=========================================="
    echo "Parameter Discovery Completed"
    echo "=========================================="

    echo
    echo "All URLs        : $PARAM_DIR/all_parameter_urls.txt"
    echo "Parameter URLs  : $PARAM_DIR/parameter_urls.txt"
    echo
}