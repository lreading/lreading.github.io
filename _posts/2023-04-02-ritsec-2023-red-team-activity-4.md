---
layout: post
title:  RITSEC 2023 - Forensics / Red Team Activity 4
summary: 'Writeup for RITSEC 2023 "Red Team Activity 4" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/forensics/red-team-activity-4
usemathjax: true
---

# Picking Up Where We Left Off
Please see [Red Team Activity 1](/blog/ritsec-ctf-2023/forensics/red-team-activity-1), [Red Team Activity 2](/blog/ritsec-ctf-2023/forensics/red-team-activity-2), and [Red Team Activity 1](/blog/ritsec-ctf-2023/forensics/red-team-activity-1) for more context on `auth.log`, `tty.log`, and why we searched for `vim` commands.

## The Challenge
The red-teamers modified a binary to **later** escalate privileges. Let's find out what they did!

## Previous Recon
In the previous 2 cases, our initial grep for `vim` done from a tty led us straight to the answer.  Unfortunately, that's not the case here!  We've already explored all of the `vim` entires, so it's time to look for something different.  If you already have root on a system, which our attackers do, a common tactic for future exploitation is [setting a SUID bit](https://materials.rangeforce.com/tutorial/2019/11/07/Linux-PrivEsc-SUID-Bit/). To keep it brief, this allows regular users to execute a file as the owner of the file without the use of `sudo` or `su`.  When the `root` user owns the file, this is as good as running it with `sudo`

## Keep Digging
How would we set the SETUID bit?  Well, there's different ways of doing it using `chmod`, so let's just start there:
```
grep 'chmod' tty.log
```
![grep 'chmod' ttyl.log](/assets/img/posts/ritsec-ctf-2023/red-team-activity-4/chmod-tty-log.png "grep 'chmod' tty.log")
<br /><br />
Here, we see that `chmod u+s` (setting the SUID) was used on `/usr/bin/find`.  This isn't something you would normally do.  Let's dig a bit deeper.
```
grep 'chmod u+s /usr/bin/find' -A 25 auth.log
```
Here, we are asking for the 25 lines AFTER the match from grep.  Again, you could use an editor if you prefer by grabbing the line number using the `-n` flag in grep.

## Why This File?
If you've never heard of [GTFOBins](https://gtfobins.github.io/), definitely check it out.  You can find a lot of pretty standard OS files that can help you escalate privs while you're attacking.  If we look at GTFOBins and search for `find`, we'll see it's listed as `Shell, SUID, Sudo`.  This is why the attackers set the SUID bit on find, so that a regular user can use it to get access as root.  According to the [GTFOBins Page on Find](https://gtfobins.github.io/gtfobins/find/):
> ./find . -exec /bin/sh -p \; -quit

This will allow you to escalate privledges when the SUID bit is set on find.
Interestingly, we see the attackers do this very command a few lines later.  First, they su from `root` to their `redteam` user.  They then run a `whoami` and `id` (presumably capturing screenshots as proof), then run `find . -exec /bin/sh -p ; -quit`.  Does this look familiar? 

## What Happens Next
If you look carefully at the log, you'll notice that after the `find` exploit is run, the UID goes from `redteam(1001)/redteam(1001)` to `root(0)/root(0)`.  This shows that the exploit worked as intended, and our attackers are able to escalate privledges in the future. 
![successful escalation in auth.log](/assets/img/posts/ritsec-ctf-2023/red-team-activity-4/escalation.png "Successful escalation in auth.log")

# Conclusion
I cannot emphasize enough how much I enjoyed this entire series of challenges.  These were my favorite part of the CTF, as I feel like CTFs are usually centered around attacking when there can be plenty of interesting _defending_ exercises.  Kudos to the authors!
