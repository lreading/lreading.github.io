---
layout: post
title:  'Making My Laptop "Leo Proof"'
summary: 'A journey into ZFS + Arch Linux for better resilience against how I tend to fail'
author: leo
date: '2026-05-04 00:00:00 -0400'
category: linux
keywords: arch linux, zfs, zfsbootmenu, disaster recovery, snapshots, backups, linux
thumbnail: /assets/img/posts/arch_zfs_laptop.png
include_thumbnail: true
permalink: /blog/making-my-laptop-leo-proof
usemathjax: true
---

I run Arch on my laptop.

Yes, I know.

I also wanted root on ZFS, native encryption, bootable mirrored drives, automatic snapshots before package upgrades, local point-in-time recovery, and enough disaster recovery discipline that I could flatten the machine without losing a weekend.

Also yes, I know this is exactly the kind of thing Nix exists to solve.

Nix is fantastic. I have tried it before, and the model is genuinely brilliant! But for my daily machine, I still value being close to the edge, I have grown to love my Arch environment, and I did not want the maintenance cost of switching my whole operating model to Nix just to make this laptop recoverable.

So I did the most reasonable possible thing:

> I made Arch more complicated.

_Extremely normal behavior, right?_

The result is an opinionated Arch root-on-ZFS installer that builds the base system I wanted:

```text
Arch Linux
linux-lts
ZFS native encryption
ZFSBootMenu
single-disk or mirrored ZFS root
mdadm RAID1 EFI system partition for two-disk installs
random encrypted swap
automatic local snapshots
automatic pre-upgrade snapshots
weekly scrubs
daily pool health checks
hibernation disabled
```

The script and README are here:

[github.com/lreading/dotfiles/tree/main/arch-zfs-install](https://github.com/lreading/dotfiles/tree/main/arch-zfs-install)

This post is the technical story behind it: what I built, what I changed from the prior art, why I made those choices, and how I tested the parts that I really did not want to discover were broken on an airplane, at a conference, or 20 minutes before an interview.

## Prior art

I did not invent this. I mostly glued together good ideas from people who already did the hard work, then adapted them to my own threat model and failure modes.

The references I leaned on most heavily:

* [r-maerz/archlinux-lts-zfs](https://github.com/r-maerz/archlinux-lts-zfs)
* [Nestor Wildner's Arch ZFS setup](https://nwildner.com/posts/2025-09-03-zfs-setup/)
* [Florian Esser's Arch Linux with ZFSBootMenu post](https://florianesser.ch/posts/20220714-arch-install-zbm/)

Huge thanks to all of them. <3

This is not meant to replace those posts - if you're considering this setup, I'd recommend you **read them first**. This is just my version, with my preferences, my mistakes, my paranoia, and my extremely specific ability to break my own computers at the worst possible time.

## The actual problem

I already had Arch running on btrfs with snapshots. In theory, that should have been enough.

In practice, I had followed a tutorial, assumed snapshots would save me, and never did a real disaster recovery test. Then I had the exact kind of dumb failures that snapshots are supposed to help with:

* a bad update
* deleting something I did not mean to delete
* realizing too late that a repo had a `.env` file I still needed
* not being completely sure what the safest recovery path was

That last bullet is the killer.

A backup or snapshot strategy you have not tested is just a motivational poster.

I already knew ZFS from running Proxmox for years. I also run TrueNAS. I am not a ZFS expert, but I understand pools, datasets, snapshots, encryption, scrub behavior, replacement flows, and enough operational footguns to know when I am doing something stupid (until ZFS proves me wrong - I'm sure it will).

So instead of starting over with a filesystem I had not learned, I chose the thing I already trusted. That mattered more than picking the thing that looked cleaner on paper.

## The goal

The goal was not "perfect security" or an enterprise level DR program.  What I wanted was to prevent me from hurting myself, and make sure that laptop failures were _boring_.  I spent some time thinking about the failure modes, and landed on the following requirements:

* recover from bad updates (looking at you, Nvidia)
* recover from accidental deletes (looking at me, Leo)
* encrypted data at rest
* no unencrypted root keyfile on disk
* two internal drives mirrored for real redundancy
* both drives independently bootable
* automated snapshots (I've proven I'm not a responsible adult)
* enough health checking to catch obvious pool problems
* a reproducible installer
* a line between base OS and userland concerns

That last point was important.

I have dotfiles. I have a Hyprland setup. I have restic. I have Backrest. I have a bunch of very Leo-specific nonsense.

The installer does not install all of that. That was intentional - I wanted the base system to be opinionated, but not a full distro. I wanted to call this project "done" at some point in 2026...

## Why ZFS on Arch is an "interesting choice"

ZFS is not in-tree for Arch. That creates friction. You need to care about kernel compatibility, DKMS, installation media, boot flow, initramfs, and a few sharp edges that most normal people avoid by making different life choices.

I started from an `archzfs-lts` ISO and intentionally used `linux-lts` with `zfs-dkms`.

```bash
pacstrap /mnt \
  base \
  linux-lts \
  linux-firmware \
  linux-lts-headers \
  zfs-dkms \
  networkmanager \
  dhcpcd
```

I know people run ZFS on the standard Arch kernel. I did not want to optimize for maximum novelty here. Arch is already a rolling release. ZFS is already out-of-tree. This whole project was about making failure boring, not making it weekly.

`linux-lts` felt like the right tradeoff. Still Arch, but slightly less like knife juggling with one hand.

## The storage layout

The installer supports one or two disks.

One disk gives you:

```text
ESP
random encrypted swap
ZFS root
```

Two disks gives you:

```text
disk A ESP  ┐
            ├─ mdadm RAID1 ESP mounted at /efi
disk B ESP  ┘

disk A swap ┐
            ├─ random encrypted swap devices
disk B swap ┘

disk A zfs  ┐
            ├─ ZFS mirror: zroot
disk B zfs  ┘
```

The partitioning is intentionally simple. 

```bash
sgdisk \
  --new=1:1MiB:+512MiB --typecode=1:ef00 --change-name=1:EFI \
  --new=2:0:+4GiB      --typecode=2:8309 --change-name=2:cryptswap \
  --new=3:0:0          --typecode=3:bf00 --change-name=3:zfsroot \
  "$disk"
```

My laptop has two of the same drive. I wanted a mirror. But I did not only want the ZFS pool mirrored. I wanted the machine to keep booting if either drive died. That meant the EFI path needed redundancy too. For two-disk installs, the installer creates an mdadm RAID1 ESP using metadata `1.0`, then formats the array as FAT32.

```bash
mdadm --create --verbose --run \
  --level=1 \
  --metadata=1.0 \
  --homehost=any \
  --raid-devices=2 \
  /dev/md/esp \
  "${ESP_PARTS[@]}"

mkfs.vfat -F 32 -n EFI /dev/md/esp
```

The metadata choice matters. The firmware needs to see something it can read as a normal FAT EFI partition, not an exciting Linux science project. I learned from my earlier mistake with btrfs, and _actually tested_ the failure modes I was worried about by using virtual machines and unplugging drives, adding new ones for the resilver, etc.

## ZFS pool choices

The pool is encrypted with ZFS native encryption:

```bash
zpool create -f -o ashift=12 \
  -O compression=lz4 \
  -O acltype=posixacl \
  -O xattr=sa \
  -O relatime=on \
  -O encryption=aes-256-gcm \
  -O keylocation="file://${ZFS_KEYFILE}" \
  -O keyformat=passphrase \
  -o autotrim=on \
  -o autoreplace=on \
  -m none \
  zroot \
  "${vdev_args[@]}"
```

The base datasets are also intentionally boring. While CIS benchmarks and security best practices say you should have separate partitions for `/tmp` and other dirs, I opted for simplicity over "perfect security". Not because I don't value security, but because the restore path needed to be simple and predictable. As a side note, I frequently work with AppImages, and if you have `noexec` set on `/tmp`... you gotta remount anyways. A security control I constantly bypass is not much of a control.

```bash
zfs create -o mountpoint=none zroot/ROOT
zfs create -o mountpoint=/ -o canmount=noauto zroot/ROOT/arch
zfs create -o mountpoint=/home zroot/home
```

Optional local datasets are mounted under `/local`.

For my own machine, the important one is `development`.

I usually work out of `~/dev`. I also keep `~/tmp` around for local-only experiments, reproductions, and things I want logically separated from repositories so I do not accidentally commit something I shouldn't:

```text
/local/development/dev
/local/development/tmp

~/dev -> /local/development/dev
~/tmp -> /local/development/tmp
```

Why not just put it under `/home`?

Development directories are noisy. I write JavaScript - `node_modules` is a black hole. Repos churn constantly. Build artifacts show up. Test data appears. I wanted the option to give this area different snapshot retention later without making restore semantics weird for the rest of my home directory.

The installer defaults to recursive snapshots, but lets selected `/local` datasets use separate retention policies, _if you want_. Just know that the restore path gets more complicated if you have different retention policies, and that's not something I spent much time testing or documenting.  You've been warned!

## The uncomfortable keyfile

A common convenience pattern with encrypted root-on-ZFS is to store a plaintext keyfile on disk so the boot process can unlock things cleanly. I get why people do it, but I explicitly didn't want that.

Look, developer machines have secrets everywhere. I work in security, I've done red teaming and incident response... I know this from having my own development machines! There are tokens in shell history, `.env` files, editor swap files, local config files, browser profiles, package manager caches, test fixtures, notes, and sometimes places so scary nobody should speak of them in daylight. I'm not trying to fix that today, but I also don't want to add to the problem if I can avoid it.

The installer uses a _temporary_ keyfile only during install:

```bash
INSTALL_RUN_DIR=/run/arch-zfs-install
ZFS_KEYFILE="${INSTALL_RUN_DIR}/zfs.key"

install -d -m 0700 "$INSTALL_RUN_DIR"
install -m 0600 /dev/null "$ZFS_KEYFILE"
printf '%s' "$ZFS_PASSPHRASE" > "$ZFS_KEYFILE"
chmod 0400 "$ZFS_KEYFILE"
```

Then, after the pool is imported and mounted, it switches the pool back to prompting:

```bash
zfs set keylocation=prompt zroot
```

And cleanup removes the temporary keyfile:

```bash
cleanup() {
  rm -f "$ZFS_KEYFILE" 2>/dev/null || true
  unset ROOT_PASSWORD ZFS_PASSPHRASE NEW_USER_PASSWORD ROOT_HASH NEW_USER_HASH
}
trap cleanup EXIT
```

This is less convenient. **Good,** that was the whole point.

## mkinitcpio, or: I learned what my initramfs actually does

Before this project, I knew enough about initramfs to be dangerous. Now I know slightly more, which is probably worse.

My `mkinitcpio` setup is focused on the pieces needed to import the pool reliably, understanding that I did not want the ZFS keyfile:

```bash
FILES=(/etc/hostid /etc/zfs/zpool.cache)
```

The hooks differ between one-disk and two-disk installs.

Single disk:

```bash
HOOKS=(base udev autodetect microcode modconf keyboard keymap block zfs filesystems)
```

Two disks:

```bash
HOOKS=(base udev autodetect microcode modconf keyboard keymap block mdadm_udev zfs filesystems)
```

That `mdadm_udev` hook matters for the mirrored ESP path. The installer also validates that the files I expect are actually present in the generated initramfs:

```bash
lsinitcpio -l /boot/initramfs-linux-lts.img | grep -q '^etc/hostid$'
lsinitcpio -l /boot/initramfs-linux-lts.img | grep -q '^etc/zfs/zpool.cache$'
```

This was one of the more useful learning parts of the project.

I had used initramfs for years without really caring about the internals. Root-on-ZFS made the boot process concrete. Suddenly `hostid`, `zpool.cache`, hook ordering, and device discovery were not trivia. They were the difference between booting and staring at a sad emergency shell... which I also got to learn pretty intimately during this process. ;) 

## ZFSBootMenu

I chose to use ZFSBootMenu - it gives me a pre-boot recovery environment that understands ZFS, snapshots, boot environments, and the actual shape of the system I built. I have a clean playbook to recover right from ZBM, and it's dead simple to use.

The installer fetches the prebuilt EFI image and installs it in two places:

```bash
mkdir -p /efi/EFI/zbm /efi/EFI/BOOT

curl -L https://get.zfsbootmenu.org/efi \
  -o /efi/EFI/zbm/zfsbootmenu.EFI

cp /efi/EFI/zbm/zfsbootmenu.EFI /efi/EFI/BOOT/BOOTX64.EFI
```

I originally fought with `efibootmgr` and firmware entries. Some systems are weird about preserving or honoring EFI boot entries, and ZFSBootMenu's docs call out the well-known fallback filename path for systems where entries do not behave.

I had another reason too: mirrored ESPs.

If my goal is "either internal drive can die and the laptop still boots," then relying on a fragile firmware entry is not the part where I want to get clever. So I not only install ZFSBootMenu to the normal path, but I also copy it to the fallback path:

```text
/efi/EFI/zbm/zfsbootmenu.EFI
/efi/EFI/BOOT/BOOTX64.EFI
```

Finally, I generate a recovery image with a more forceful import policy:

```bash
curl -L https://get.zfsbootmenu.org/efi/recovery \
  -o /root/zfsbootmenu.recovery.EFI

zbm-kcl \
  -a "spl_hostid=0x$(hostid)" \
  -a 'zbm.prefer=zroot!!' \
  -a 'zbm.import_policy=force' \
  -a 'zbm.set_hostid=1' \
  -a 'zbm.timeout=-1' \
  /root/zfsbootmenu.recovery.EFI
```

The normal image uses a stricter hostid import policy. The recovery image exists for the day I need to be less polite.

That day will come... I know myself.

## Automatic snapshots before upgrades

This is the part I care about most. Arch is a rolling release. The vast majority of upgrades work with no issues, but the ones that break usually break stuff in a spectacular way.

The responsible thing to do before a full upgrade is take a snapshot.

The Leo thing to do is forget, run the upgrade anyway, and then spend an entire evening fixing the system and swearing a lot.

I did not want a policy. Policies require me to remember things. The installer writes a pacman ALPM hook, which was also an exciting new concept for me!

```ini
[Trigger]
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Create recursive ZFS snapshot before package upgrades
When = PreTransaction
Exec = /usr/local/sbin/zfs-prepacman-snapshot
AbortOnFail
```

Before package upgrades, the hook creates a recursive snapshot:

```bash
snapshot_name="pre_update_$(date -u +%Y%m%dT%H%M%SZ)"
zfs snapshot -r "zroot@${snapshot_name}"
```

It keeps the newest seven by default:

```bash
PREPACMAN_KEEP=7
```

If the snapshot fails, pacman aborts before changing packages.

I do not want to find out my safety net failed after the system is already half-upgraded.

This is the same pattern I like in security engineering, even though calling local ZFS snapshots "security" is a bit of a stretch.

> Make the safe path the easy path.

Better yet, make the safe path the default path.

Best case: make the safe path the path I cannot forget, because there is no manual piece for me to remember.

## Periodic snapshots

The installer also writes a small snapshot system using systemd timers.

The default retention is:

```bash
10min   20
hourly  10
daily   7
weekly  4
monthly 6
```

The default policy uses recursive `zroot` snapshots so root, home, and inherited local datasets line up under the same snapshot names.

A snapshot named `autosnap_default_hourly_20260419T143000Z` should describe a coherent point in time, not a scavenger hunt. If I configure a `/local` dataset with its own policy, the installer stops using one recursive default snapshot and writes explicit dataset-level snapshot behavior instead.

That is more flexible, but less magically coherent.

Again: tradeoffs.

The point is not to hide them from myself.

## Snapshot retention is not optional

Snapshots feel free until they are not. A laptop disk can go from "plenty of space" to "why is everything broken" shockingly fast if snapshots retain too much churn... and development machines ***churn***.

The snapshot scripts check pool capacity and log warnings before creating snapshots:

```bash
capacity="$(zpool list -H -o capacity "$POOL" | tr -d '%')"

if ((capacity >= CAPACITY_CRITICAL)); then
  logger -p daemon.err -t zfs-autosnapshot \
    "pool ${POOL} is ${capacity}% full; creating snapshot but capacity is critical"
elif ((capacity >= CAPACITY_WARN)); then
  logger -p daemon.warning -t zfs-autosnapshot \
    "pool ${POOL} is ${capacity}% full"
fi
```

Warnings do not solve everything, but "my snapshots ate my laptop" was a failure mode I could predict, so I built at least a little guardrail.

## Scrubs, health checks, and ZED logging

Since I was already writing the maintenance layer, I added the boring stuff too.

Weekly scrub:

```ini
[Timer]
OnCalendar=Sun *-*-* 03:30
Persistent=true
AccuracySec=1h
```

Daily pool health and capacity check:

```bash
health="$(zpool get -H -o value health "$POOL")"
if [[ "$health" != "ONLINE" ]]; then
  logger -p daemon.err -t zfs-health-check "pool ${POOL} health is ${health}"
  zpool status "$POOL"
  status="1"
fi
```

I also added a ZED hook that logs meaningful pool state changes through systemd. This is not fancy observability. It is a laptop, but I wanted enough breadcrumbs that if something starts going sideways, I am not completely blind.

## Hibernation is disabled

Root-on-ZFS and hibernation are not friends. I heard the warnings. I might usually say "hold my beer", but when we're talking data loss?  Ehhhhhh.  Also, I've learned two things about myself:

- I heed warnings and will absolutely remember them later
- Future Leo is a liar and often forgets the warnings

So I made the installer disable hibernation to prevent that dang lying Leo from striking again:

```ini
[Sleep]
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
```

It also masks the relevant systemd targets:

```bash
systemctl mask \
  hibernate.target \
  hybrid-sleep.target \
  suspend-then-hibernate.target
```

At this point, you're probably noticing a trend. I don't want to document the things I can't afford to forget: I want to forget them entirely, because I protected myself with good guardrails and automation.

## Pipe to Bash

Every security nerd will tell you how safe it is to pipe random scripts to bash, right? ...RIGHT?

That said, I did author the script, albeit with a bit of help from our robot friends. I tested it extensively, and I was confident that it was going to work well ***for my use case***.  _I make no guarantees about the script for your use case, please review it and use with caution_.

I just wanted to be able to run it quickly: just host it somewhere, curl it, and pipe it to bash.

Something like:

```bash
curl http://10.10.13.20:3000/arch-zfs-installer.sh | bash
```

Or from wherever I am hosting the script at the time.

That is why the script insists on a controlling TTY:

```bash
TTY=/dev/tty

require_tty() {
  [[ -r "$TTY" && -w "$TTY" ]] || \
    die "A controlling TTY is required. This script is safe for curl | bash, but it must be run interactively."
}
```

## Fat-finger protection

The script is destructive, so it tries to make dumb mistakes harder. It lists available whole disks, asks for one or two disk numbers, rejects duplicates, rejects mounted disks, and requires typing `WIPE` before doing anything destructive.

```text
ALL DATA ON THE TARGET DISK(S) ABOVE WILL BE DESTROYED.
Type WIPE to continue. Anything else aborts.
```

I'll admit I'm clumsy, but I also know I'm not the only one. We all fat-finger things from time to time. How many times have you told someone via text message to "duck off"?

We all have fat fingers. Mine just have commit access.

## Testing strategy

I tested this in Proxmox before putting it on the laptop... A lot. Like, an egregious amount.

The early versions were bad. Some booted once. Some installed beautifully and then failed after reboot. Some worked until I simulated the thing they were specifically supposed to survive. Very rude.

The important tests were:

1. Install with one disk.
2. Install with two disks.
3. Boot from the mirrored install.
4. Remove one virtual disk while running.
5. Reboot with one disk missing.
6. Confirm the system still boots.
7. Add a brand new unformatted disk.
8. Replace the missing side of the ZFS mirror.
9. Rebuild the mdadm ESP mirror.
10. Repeat from the other side.

This testing isn't perfect, but it covers the failure modes that I was trying to solve.

And again, this was... for my laptop. This isn't a multi-billion dollar enterprise BCP/DR exercise.

## What this does not do

It does not install a desktop environment.

It does not restore any dotfiles.

It does not install any unnecessary packages.

This line in the sand was intentional. The more user-specific I made this, the less useful it became to anyone else, and the more likely I was to turn a recovery project into my own terrible distro. 

The base installer owns the base system:

```text
storage
boot
encryption
snapshots
maintenance
basic users
basic networking
```

Userland recovery is another layer.

For file-level recovery, I use restic and Backrest outside this installer. That gives me recovery for the classic developer-machine mistake: deleting a repo and then realizing the `.env` file mattered.

ZFS snapshots are great for local point-in-time recovery.

Backups are for when the laptop is gone, destroyed, stolen, or otherwise promoted to "learning experience."

## The result

I have been driving this setup for about three or four weeks now, and so far, so good!

The funny part is that after reinstalling, restoring what I needed, and letting my dotfiles do their thing, the machine stopped feeling new almost immediately. After about an hour of setup, I legitimately forgot I had reformatted it. It just felt like my laptop the way it was before reformatting. That is so boring and predictable, in the best possible way.

This project is extremely nerdy, in the most practical way. I'm not claiming this is the most elegant possible Arch install. I built this because I know how I fail:

* I move fast.
* I forget manual safety steps.
* I delete things before thinking.
* I run rolling-release upgrades because apparently I enjoy a little danger.
* I do not want to relearn recovery under pressure.

So I built a system around that.

Not perfect, just harder for me to break accidentally.

> Leo Proof.

If I hit any serious issues, I will write a follow-up! This is absolutely an experiment, and I'm learning as I go.

If you see something wrong, have a better pattern, or want to suggest an improvement, I do not have comments enabled on the blog. Open an issue or PR here instead:

[github.com/lreading/lreading.github.io](https://github.com/lreading/lreading.github.io)

