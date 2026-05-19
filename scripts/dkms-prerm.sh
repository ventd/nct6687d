#!/bin/sh
# DKMS PRE_REMOVE hook for ventd/nct6687d.
#
# Removes the modprobe.d blacklist drop-in we installed in dkms-postinst.sh.
# Runs before the module is unbuilt, so that if the user is going back to
# the in-tree nct6683 (or to a different fan-control stack) they don't
# inherit a stale blacklist on next boot.

set -eu

DST="/etc/modprobe.d/blacklist-nct6683-by-ventd.conf"

if [ -f "${DST}" ]; then
    rm -f "${DST}"
    echo "ventd/nct6687d: removed ${DST}" >&2
fi
