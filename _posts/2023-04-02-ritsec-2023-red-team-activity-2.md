---
layout: post
title:  RITSEC 2023 - Forensics / Red Team Activity 2
summary: 'Writeup for RITSEC 2023 "Red Team Activity 2" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/forensics/red-team-activity-2
usemathjax: true
---

# Picking Up Where We Left Off
In [Red Team Activity 1](/blog/ritsec-ctf-2023/forensics/red-team-activity-1), we filtered the provided `auth.log` down to only commands run from a TTY, and then found all `vim` commands that were run.  This writeup will reference `tty.log`, which was created in the previous exercise by running `grep -v 'tty:(none)' auth.log > tty.log`

## The Challenge
We were asked to find the name of the malicious service.  Looking at our screenshot of `vim` entries from `tty.log`, we can actually see that a service called `bluetoothd.service` was touched.  If this is a server and not a desktop, I'm not sure why we would ever want a bluetooth service running... This seems sus.
![grep 'vim' ttyl.log](/assets/img/posts/ritsec-ctf-2023/red-team-activity-1/grep-vim-tty-log.png "grep 'vim' tty.log")

## Looking further into it
So we know that there's probably more context around that entry.  Let's find the entry in the full `auth.log` to see what was going on around that time:
```
grep -n 'bluetoothd.service' auth.log
```
In the above command, the `-n` flag tells grep to provide the line number.  We can see that the entries are on lines 252 and 253 of `auth.log`.  With this information, we can open the file in your favorite editor/reader/whatever you want to use and skip to that line number.  

## What else is going on here?
Well, the attackers add the service and then enable it using `systemctl`, and then look at the `auth.log` file to see if their activity is being recorded.  Their very next move is to instapp apache2, which is a bit odd.  We don't see any logout inbetween, and the command is using the same TTY.  This is interesting, and we may want to remember that for later.

# Conclusion
I enjoy that these challenges are really continuations of the previous challenge.  Additionally, if you're filtering in a smart way, they become way easier to pinpoint the attacks and what the red-teamers did.  As an exercise for fun, you could look for other interesting commands such as `adduser` or `useradd` to see if they are creating a user for persistence, or maybe even `authorized_keys`. 
