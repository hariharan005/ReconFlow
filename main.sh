#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Banner
source "$SCRIPT_DIR/modules/Banner.sh"

# Modules
source "$SCRIPT_DIR/modules/Basic_Info.sh"
source "$SCRIPT_DIR/modules/subdomain_recon.sh"
source "$SCRIPT_DIR/modules/httpx.sh"
source "$SCRIPT_DIR/modules/Ip_Getter.sh"
source "$SCRIPT_DIR/modules/Port_Scanner.sh"
source "$SCRIPT_DIR/modules/Dir_Enum.sh"
source "$SCRIPT_DIR/modules/Crawling.sh"
source "$SCRIPT_DIR/modules/Parameter_Discovery.sh"
source "$SCRIPT_DIR/modules/JS_Enum.sh"
source "$SCRIPT_DIR/modules/Screenshots.sh"
source "$SCRIPT_DIR/modules/Vuln_Scan.sh"

# -----------------------------
# Read Domain
# -----------------------------
read -erp "Enter the Domain Name: " domain_name

REPORT_DIR="reports/$domain_name"

mkdir -p "$REPORT_DIR"

export domain_name
export REPORT_DIR

# -----------------------------
# Helper Function
# -----------------------------
run_module() {

    local module_name="$1"
    shift

    echo
    echo "=========================================="
    echo "[*] Running : $module_name"
    echo "=========================================="

    if "$@"
    then
        echo "[✓] $module_name Completed Successfully"
    else
        echo "[✗] $module_name Failed"
    fi

    echo
}

# -----------------------------
# Run All
# -----------------------------
run_all() {

    echo
    echo "Starting Full Recon..."
    echo

    run_module "Subdomain Enumeration" subdomain_recon
    run_module "HTTPX Recon" httpx_recon
    run_module "Basic Information" Basic_Info
    run_module "IP Getter" Ip_Getter
    run_module "Port Scanner" Port_Scanner
    run_module "Directory Enumeration" Dir_Enum
    run_module "Crawling" crawling
    run_module "Parameter Discovery" Parameter_Discovery
    run_module "JavaScript Enumeration" JS_Enum
    run_module "Screenshot Enumeration" Screenshot_Enum
    run_module "Vulnerability Scanning" Vuln_Scan
    
    echo
    echo "=========================================="
    echo "Recon Completed"
    echo "Reports saved in:"
    echo "$REPORT_DIR"
    echo "=========================================="
}

# -----------------------------
# Menu
# -----------------------------
while true
do

    echo
    echo "=========================================="
    echo "              ReconFlow Menu"
    echo "=========================================="
    echo
    echo "Target : $domain_name"
    echo
    echo " 1. Subdomain Enumeration"
    echo " 2. HTTPX Recon"
    echo " 3. Basic Information"
    echo " 4. IP Getter"
    echo " 5. Port Scanner"
    echo " 6. Directory Enumeration"
    echo " 7. Crawling"
    echo " 8. Parameter Discovery"
    echo " 9. JavaScript Enumeration"
    echo " 10. Screenshot Enumeration"
    echo " 11. Vulnerability Scanning"
    echo " 12. Run All Recon"
    echo " 13. Change Target Domain"
    echo " 14. Exit"
    echo

    read -rp "Select Option: " option

    case "$option" in

        1)
            run_module "Subdomain Enumeration" subdomain_recon
            ;;
        2)
            run_module "HTTPX Recon" httpx_recon
            ;;
        3)
            run_module "Basic Information" Basic_Info
            ;;
            

        4)
            run_module "IP Getter" Ip_Getter
            ;;

        5)
            run_module "Port Scanner" Port_Scanner
            ;;

        6)
            run_module "Directory Enumeration" Dir_Enum
            ;;

        7)
            run_module "Crawling" crawling
            ;;
        8)
            run_module "Parameter Discovery" Parameter_Discovery
            ;;
        9)
            run_module "JavaScript Enumeration" JS_Enum
            ;;

        10)
            run_module "Screenshot Enumeration" Screenshot_Enum
            ;;
        11)
            run_module "Vulnerability Scanning" Vuln_Scan
            ;;
        12)
            run_all
            ;;
        13)
            read -rp "Enter New Domain: " domain_name
            REPORT_DIR="reports/$domain_name"
            mkdir -p "$REPORT_DIR"
            export domain_name
            export REPORT_DIR
            ;;
        14)
            echo
            echo "Thank you for using ReconFlow."
            exit 0
            ;;
        *)
            echo
            echo "Invalid Option!"
            ;;
    esac
done