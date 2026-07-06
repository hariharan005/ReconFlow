#!/bin/bash

#Function to get the IP address of the domain name using nmap and awk 
IP(){
    nmap -sL -n $domain_name | awk '/Nmap scan report for/{print "IP: "$NF}' | tr -d '()'
}

Dig(){
    echo
    echo "=== DNS Records for $domain_name ==="
    echo
    for type in A AAAA MX NS TXT CNAME SOA ; 
    do

        echo "=== $type ==="
        echo
        dig "$domain_name" "$type" +short
        echo
    done
}

#Call the function to get the IP address of the domain name
Basic_Info(){

    output_file="$REPORT_DIR/Basic_Info.txt"
    {
        echo "=== Basic Information for $domain_name ==="
        echo
        echo "IP Address:"
        IP
        echo
        Dig
    } | tee "$output_file"
    echo
    echo "Output saved to $output_file"
}