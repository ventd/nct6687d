# ventd downstream fork

This is the [ventd](https://github.com/ventd/ventd) project's downstream fork of
[Fred78290/nct6687d](https://github.com/Fred78290/nct6687d) — the
out-of-tree Linux driver for Nuvoton NCT6687D Super-I/O chips found on most
modern MSI motherboards (and some ASRock / Mitac boards).

ventd ships this driver to end users because the in-tree `nct6683` driver
matches the same chip ID but is **read-only** — it has no `pwm*` write path,
no `pwm_enable`, no fan curves. Without `nct6687`, ventd can monitor those
boards but cannot control them.

## What this fork adds over upstream

The patch set against upstream is intentionally small so we can keep rebasing
cleanly when Fred78290/nct6687d moves. The ventd-specific changes live on the
`ventd` branch and are:

1. **`modprobe.d/blacklist-nct6683-by-ventd.conf`** — installed to
   `/etc/modprobe.d/` by the DKMS install hook. The in-tree `nct6683` driver
   binds first at boot and reports zeros / wrong values on NCT6687D-equipped
   boards; ventd's controller cannot work around that, so we blacklist it.
   Removed cleanly on uninstall.
2. **`scripts/dkms-postinst.sh` / `scripts/dkms-prerm.sh`** — DKMS install/
   uninstall hooks wired up via `POST_INSTALL=` / `PRE_REMOVE=` in `dkms.conf`.
   They drop in (and remove) the blacklist file above. Distro-agnostic so a
   plain `dkms install nct6687d/<ver>` does the right thing even outside the
   `.deb` / `.rpm` install paths.

That's the whole patch set. Anything else of broad value gets sent upstream
as a PR to Fred78290/nct6687d first.

## How ventd uses this fork

ventd's installer pins to a specific tag of this repo (e.g.
`v1.0.0-ventd.1`) and fetches the source via the `BASE_URL=`
`https://github.com/${VENTD_REPO}/releases/download/${VENTD_VERSION}` pattern
baked into the `ventd` binary. Once unpacked, ventd's preflight runs
`dkms install`, which triggers the POST_INSTALL hook above — at which point
the blacklist is in place, `nct6683` won't bind on next boot, and ventd's
controller can drive the chip.

If you're not a ventd user and just want the driver, upstream
[Fred78290/nct6687d](https://github.com/Fred78290/nct6687d) is the
authoritative source — this fork exists for ventd's deployment needs, not as
a replacement for upstream.

## Syncing with upstream

```sh
git remote add upstream https://github.com/Fred78290/nct6687d.git
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git checkout ventd
git rebase main
```

Tag new ventd releases off the `ventd` branch as `v<upstream-ish>-ventd.<n>`.

## License

Inherited from upstream: GPL-2.0-or-later. See [LICENSE](LICENSE).
