#!/bin/bash

echo "=== MapR Repository Cleanup Script ==="

# Function to cleanup MapR repositories
cleanup_mapr_repos() {
    echo "Removing all MapR repository files..."
    
    # Remove all possible MapR repository files
    rm -f /etc/yum.repos.d/MapR*.repo
    rm -f /etc/yum.repos.d/mapr*.repo  
    rm -f /etc/yum.repos.d/MapR*.repo.disabled
    rm -f /etc/yum.repos.d/mapr*.repo.disabled
    
    # Clean all yum caches
    echo "Cleaning yum caches..."
    yum clean all
    rm -rf /var/cache/yum/*
    
    # Remove any GPG keys
    echo "Removing MapR GPG keys..."
    rm -f /tmp/maprgpg.key
    
    # Rebuild yum cache without MapR repos
    echo "Rebuilding yum cache..."
    yum makecache 2>/dev/null || true
    
    # Verify cleanup
    echo "=== Verification ==="
    echo "MapR repository files remaining:"
    ls -la /etc/yum.repos.d/MapR* /etc/yum.repos.d/mapr* 2>/dev/null || echo "No MapR repo files found"
    
    echo "MapR repositories in yum:"
    yum repolist | grep -i mapr || echo "No MapR repositories found"
    
    echo "=== Cleanup Complete ==="
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Run cleanup
cleanup_mapr_repos

echo "MapR repository cleanup completed successfully!" 