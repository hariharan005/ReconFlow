#!/bin/bash

#Read the domain name from user input and store it in a variable
read -p "Enter the Domain Name: " domain_name
echo "Domain Name: $domain_name"

#Function to get the IP address of the domain name using nmap and awk 
function IP(){
    echo "From Client Side: $domain_name"
    nmap -sL -n $domain_name | awk '/Nmap scan report for/{print "IP: "$NF}' | tr -d '()'
}

#Call the function to get the IP address of the domain name
IP