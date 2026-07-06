#!/bin/bash

# This script is the main entry point for the ReconFlow tool. It displays a banner.
source modules/Banner.sh

#Read the domain name from user input and store it in a variable
read -p "Enter the Domain Name: " domain_name
echo "Domain Name: $domain_name"

REPORT_DIR="reports/$domain_name"

mkdir -p "$REPORT_DIR"

#call the Get_IP.sh script to get the IP address of the domain name
source modules/Basic_Info.sh

# call the subdomain_recon.sh script to perform subdomain enumeration
source modules/subdomain_recon.sh

# call the httpx.sh script to perform HTTPX reconnaissance 
source modules/httpx.sh

# call the Ip_Getter.sh script to get IP addresses of all subdomains
source modules/Ip_Getter.sh

Basic_Info
subdomain_recon
httpx_recon
Ip_Getter

export REPORT_DIR
export domain_name