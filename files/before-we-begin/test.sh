#!/bin/bash
echo "Checking if /etc/os-release exists..."
test -f /etc/os-release && echo "PASS: file exists" || exit 1

echo "Checking if bash is available..."
bash --version > /dev/null && echo "PASS: bash works" || exit 1

echo "All checks passed."

