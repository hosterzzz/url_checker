#!/bin/bash

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> diagnostics.log
}

# Function to perform diagnostic tests
perform_diagnostics() {
    local url=$1
    local hostname=$(echo "$url" | awk -F[/:] '{print $4}')
    
    echo "Running all diagnostics for $hostname..."
    log_message "Starting all diagnostics for $hostname"
    
    echo "1. Running ping test..."
    log_message "Running ping test for $hostname"
    ping -c 4 $hostname >> diagnostics.log 2>&1
    
    echo "2. Running traceroute..."
    log_message "Running traceroute for $hostname"
    traceroute -m 10 -w 1 $hostname >> diagnostics.log 2>&1
    
    echo "3. Running NSLookup..."
    log_message "Running NSLookup for $hostname"
    nslookup $hostname >> diagnostics.log 2>&1
    
    echo "4. Checking SSL Certificate..."
    log_message "Checking SSL Certificate for $hostname"
    echo | openssl s_client -servername "$hostname" -connect "$hostname:443" 2>/dev/null | openssl x509 -noout -dates -subject -issuer >> diagnostics.log 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ SSL Certificate check completed"
        echo "Check diagnostics.log for certificate details"
    else
        echo "✗ SSL Certificate check failed"
        log_message "SSL Certificate check failed for $hostname"
    fi
    
    echo "All diagnostics completed - check diagnostics.log for details"
}

# Main script
if [ $# -eq 0 ]; then
    echo "Usage: $0 <URL>"
    echo "Example: $0 https://example.com/health"
    exit 1
fi

url=$1

# Extract hostname from URL
hostname=$(echo "$url" | awk -F[/:] '{print $4}')

if [ -z "$hostname" ]; then
    echo "Invalid URL format"
    log_message "Error: Invalid URL format - $url"
    exit 1
fi

log_message "Starting check for URL: $url"

# Perform HTTP request and check status code and content
response=$(curl -s -w "\n%{http_code}" "$url")
status_code=$(echo "$response" | tail -n1)
content=$(echo "$response" | sed '$d')

log_message "HTTP Status Code: $status_code"

if [ "$status_code" = "200" ]; then
    if echo "$content" | grep -qi "success"; then
        echo "URL check passed:"
        echo "✓ Status code is 200"
        echo "✓ Content contains 'success' (case insensitive)"
        log_message "Check passed - Status: 200, Content contains 'success'"
    else
        echo "URL check partially failed:"
        echo "✓ Status code is 200"
        echo "✗ Content does not contain 'success' (case insensitive)"
        log_message "Check failed - Content does not contain 'success'"
        perform_diagnostics "$url"
    fi
else
    echo "URL check failed:"
    echo "✗ Status code is not 200 (Got: $status_code)"
    log_message "Check failed - Invalid status code: $status_code"
    perform_diagnostics "$url"
fi 