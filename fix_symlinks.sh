#!/bin/bash
# Fix rsync symlink conflicts for recovery build
# This script removes etc and vendor directories from recovery root
# to allow the build system to create symlinks

RECOVERY_ROOT="$1"

if [ -d "$RECOVERY_ROOT" ]; then
    # Remove etc and vendor if they are directories (not symlinks)
    if [ -d "$RECOVERY_ROOT/etc" ] && [ ! -L "$RECOVERY_ROOT/etc" ]; then
        echo "Removing $RECOVERY_ROOT/etc directory"
        rm -rf "$RECOVERY_ROOT/etc"
    fi

    if [ -d "$RECOVERY_ROOT/vendor" ] && [ ! -L "$RECOVERY_ROOT/vendor" ]; then
        echo "Removing $RECOVERY_ROOT/vendor directory"
        rm -rf "$RECOVERY_ROOT/vendor"
    fi
fi
