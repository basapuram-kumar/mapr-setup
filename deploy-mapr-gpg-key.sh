#!/bin/bash

# Script to manually download and deploy MapR GPG key to all nodes
# Use this if automatic download fails due to connectivity issues

echo "=== MapR GPG Key Deployment Script ==="

# MapR repository credentials
MAPR_USERNAME="john.whitmore@acceldata.io"
MAPR_PASSWORD="X8ZjKlYgOSq2VEg1eVuzgi4Yud8c-qBVjQyKubWi5WfkJ2D2yYNQeEIDrr0pf7DEY0SxU8cgXR78JwZzMzc4Ig"
MAPR_GPG_URL="https://package.ezmeral.hpe.com/releases/pub/maprgpg.key"

# Function to download GPG key
download_gpg_key() {
    echo "Attempting to download MapR GPG key..."
    
    # Try multiple methods
    
    # Method 1: curl with authentication
    echo "Method 1: Using curl with authentication..."
    if curl -k --connect-timeout 60 --max-time 120 --retry 3 --retry-delay 10 \
            -u "$MAPR_USERNAME:$MAPR_PASSWORD" \
            -o /tmp/maprgpg.key \
            "$MAPR_GPG_URL"; then
        echo "✓ Downloaded MapR GPG key successfully with curl"
        return 0
    fi
    
    # Method 2: wget with authentication
    echo "Method 2: Using wget with authentication..."
    if wget --no-check-certificate --timeout=60 --tries=3 --wait=10 \
            --user="$MAPR_USERNAME" --password="$MAPR_PASSWORD" \
            -O /tmp/maprgpg.key \
            "$MAPR_GPG_URL"; then
        echo "✓ Downloaded MapR GPG key successfully with wget"
        return 0
    fi
    
    # Method 3: Basic curl without SSL verification
    echo "Method 3: Using basic curl..."
    if curl -k -L --connect-timeout 60 --max-time 120 \
            -o /tmp/maprgpg.key \
            "$MAPR_GPG_URL"; then
        echo "✓ Downloaded MapR GPG key successfully with basic curl"
        return 0
    fi
    
    echo "✗ All download methods failed"
    return 1
}

# Function to verify GPG key
verify_gpg_key() {
    if [ -f /tmp/maprgpg.key ]; then
        echo "GPG key file size: $(du -h /tmp/maprgpg.key)"
        echo "GPG key content preview:"
        head -5 /tmp/maprgpg.key
        return 0
    else
        echo "✗ GPG key file not found"
        return 1
    fi
}

# Function to import GPG key
import_gpg_key() {
    echo "Importing MapR GPG key..."
    if rpm --import /tmp/maprgpg.key 2>/dev/null; then
        echo "✓ GPG key imported successfully"
        return 0
    else
        echo "✗ Failed to import GPG key"
        return 1
    fi
}

# Function to deploy to all nodes
deploy_to_all_nodes() {
    echo "Deploying GPG key to all cluster nodes..."
    
    # List of nodes - update these IPs as needed
    NODES="10.100.7.49 10.100.7.50 10.100.7.51 10.100.7.52"
    
    for node in $NODES; do
        echo "Deploying to node: $node"
        
        # Copy GPG key to node
        if scp /tmp/maprgpg.key root@$node:/tmp/maprgpg.key; then
            echo "  ✓ Copied GPG key to $node"
            
            # Import GPG key on node
            if ssh root@$node "rpm --import /tmp/maprgpg.key"; then
                echo "  ✓ Imported GPG key on $node"
            else
                echo "  ✗ Failed to import GPG key on $node"
            fi
        else
            echo "  ✗ Failed to copy GPG key to $node"
        fi
    done
}

# Function for connectivity diagnostics
run_diagnostics() {
    echo "=== Connectivity Diagnostics ==="
    
    echo "1. Testing DNS resolution:"
    nslookup package.ezmeral.hpe.com || echo "DNS resolution failed"
    
    echo "2. Testing connectivity:"
    ping -c 3 package.ezmeral.hpe.com || echo "Ping failed"
    
    echo "3. Testing HTTPS connectivity:"
    curl -k --connect-timeout 10 -I https://package.ezmeral.hpe.com/ || echo "HTTPS connection failed"
    
    echo "4. Checking proxy settings:"
    echo "HTTP_PROXY: ${HTTP_PROXY:-not set}"
    echo "HTTPS_PROXY: ${HTTPS_PROXY:-not set}"
    echo "NO_PROXY: ${NO_PROXY:-not set}"
}

# Main execution
main() {
    case "${1:-download}" in
        "download")
            download_gpg_key && verify_gpg_key
            ;;
        "import")
            import_gpg_key
            ;;
        "deploy")
            if [ -f /tmp/maprgpg.key ]; then
                deploy_to_all_nodes
            else
                echo "GPG key not found. Run with 'download' first."
                exit 1
            fi
            ;;
        "all")
            download_gpg_key && verify_gpg_key && import_gpg_key && deploy_to_all_nodes
            ;;
        "diagnostics")
            run_diagnostics
            ;;
        *)
            echo "Usage: $0 [download|import|deploy|all|diagnostics]"
            echo "  download    - Download GPG key only"
            echo "  import      - Import GPG key on current node"
            echo "  deploy      - Deploy GPG key to all nodes"
            echo "  all         - Do download + import + deploy"
            echo "  diagnostics - Run connectivity diagnostics"
            exit 1
            ;;
    esac
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

main "$@" 