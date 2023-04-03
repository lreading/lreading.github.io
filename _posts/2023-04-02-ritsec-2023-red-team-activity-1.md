---
layout: post
title:  RITSEC 2023 - Forensics / Red Team Activity 1
summary: 'Writeup for RITSEC 2023 "Red Team Activity 1" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/forensics/red-team-activity-1
usemathjax: true
---

# Digging Through Logs
If you're reading this, you already know I'm a nerd. If that point wasn't already clear enough, let me tell you how excited I was about challenges that have you digging through server logs to piece together what could have happened!  Even better, it was from a Linux server, so this was kind of up my alley. Having spent quite some time as a blue-teamer, I was pretty confident going into this.  Hopefully some of thet tips and tricks I share here can help you in the future!

# Auth.log
We are given an `auth.log` file, and asked to give the name of the script that was dropped on the server.  Let's tear into it! The log file is 13,647 lines long, so either there's a ton of activity on the server, or this is more of a syslog than a traditional `auth.log` file.
![wc -l auth.log](/assets/img/posts/ritsec-ctf-2023/red-team-activity-1/auth-log-lines.png "wc -l auth.log")

## Filtering out the Noise
There's a lot of noise in this file.  There's plenty of things that are just typical behavior on an Ubuntu machine.  In order to find out what's going on here, we need to filter some of that noise out.  I've played a fair amount of [HackTheBox](https://www.hackthebox.eu), and I know that as a red-teamer, I'd want to be working on a proper TTY. Let's see if we can limit the file down to only the entires that were done from a TTY:
```
grep -v 'tty:(none)' auth.log > tty.log
```
The above command uses grep to filter OUT the lines that have `tty:(none)` in them, leaving us with only logs from where a proper TTY was used.  This file is now only 771 lines long, which is a lot better than 13k!
<br /><br />
![wc -l tty.log](/assets/img/posts/ritsec-ctf-2023/red-team-activity-1/tty-log-lines.png "wc -l tty.log")

## What Would I Do?
While our `tty.log` file is significantly smaller, we can make some educated guesses on how a script was dropped.  Starting out, I decided to focus in on the following commands:
- curl
- wget
- vim
- vi
- nano
Why these commands?  They're how I would go about getting a script onto a linux machine.  It will either be downloaded or manually added to the machine.  I ran the following and looked at the lines for each, until I found what I was looking for when searching for `vim`:
<br /><br />
![grep 'vim' ttyl.log](/assets/img/posts/ritsec-ctf-2023/red-team-activity-1/grep-vim-tty-log.png "grep 'vim' tty.log")

## What Did We Just Find?
Well, interestingly enough, we actually found the answers to at least two other challenges here. but we can see that someone created a script in `/dev/shm/_script2980.sh`.  That certainally seems a bit odd, and is probably what we're looking for.  I did a MD5sum of the name of the script and plugged it into the flag format, and boom!  Another flag down.  Let's look at the other red team activity challenges now.

# Conclusion
I loved this challenge, as it showcases why off-site logging is so important.  If you look carefully at the above screenshot, you can actually see that the attacker **edited** auth.log.  In theory, if the logs are only stored locally, they could have erased their tracks and incident responders would have even less data to work with.
