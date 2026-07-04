#!/bin/bash

#Read the domain name from user input and store it in a variable
read -p "Enter the Domain Name: " domain_name
echo "Domain Name: $domain_name"

output_file="Basic_Info_${domain_name}_output.txt"

#Function to get the IP address of the domain name using nmap and awk 
function IP(){
    nmap -sL -n $domain_name | awk '/Nmap scan report for/{print "IP: "$NF}' | tr -d '()'
}

function Dig(){
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
{
    echo "Dig Results for $domain_name"
    echo "Domain Name: $domain_name"
    echo "==================="
    echo

    IP
    Dig
} | tee "$output_file"

echo
echo "Output saved to $output_file"