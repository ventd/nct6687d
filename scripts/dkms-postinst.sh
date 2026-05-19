#!/bin/sh
# DKMS POST_INSTALL hook for ventd/nct6687d.
#
# Drops the modprobe.d blacklist for the conflicting in-tree nct6683 driver
# into /etc/modprobe.d/ so that on next boot the out-of-tree nct6687 wins.
# Idempotent — safe to re-run on every kernel rebuild.
#
# DKMS invokes POST_INSTALL with the source tree as cwd, so the relative
# path below is correct. We do not call `update-initramfs` / `dracut` here:
# nct6683/nct6687 are not in the initramfs on any distro we ship to, and
# the blacklist only needs to be in place by the time userspace runs.

set -eu

SRC="modprobe.d/blacklist-nct6683-by-ventd.conf"
DST="/etc/modprobe.d/blacklist-nct6683-by-ventd.conf"

if [ ! -f "${SRC}" ]; then
    echo "ventd/nct6687d POST_INSTALL: ${SRC} missing — skipping blacklist install" >&2
    exit 0
fi

install -m 0644 -D "${SRC}" "${DST}"
echo "ventd/nct6687d: installed ${DST}" >&2
