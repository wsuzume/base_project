#!/bin/sh

echo "* SSH key generation"

echo -n "Input comment for ssh-keygen ( generally, it's your email address ): "
read COMMENT

set -x
ssh-keygen -t rsa -b 4096 -C "${COMMENT}"
set +x
