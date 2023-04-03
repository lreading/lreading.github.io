---
layout: post
title:  RITSEC 2023 - Forensics / Red Team Activity 3
summary: 'Writeup for RITSEC 2023 "Red Team Activity 3" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/forensics/red-team-activity-3
usemathjax: true
---

# Picking Up Where We Left Off
Please see [Red Team Activity 1](/blog/ritsec-ctf-2023/forensics/red-team-activity-1) and [Red Team Activity 2](/blog/ritsec-ctf-2023/forensics/red-team-activity-2) for more context on `auth.log`, `tty.log`, and why we searched for `vim` commands.

## The Challenge
This time, we were asked tofind the location of the script that ran _repeatedly_ (emphasis mine).  On linux, what do you think of when you want to run something over and over in an unattended way?  [Cron](https://en.wikipedia.org/wiki/Cron), of course! 

## Our Initial Filter FTW
![grep 'vim' ttyl.log](/assets/img/posts/ritsec-ctf-2023/red-team-activity-1/grep-vim-tty-log.png "grep 'vim' tty.log")
I kind of feel bad leaving this post so short, but... if you already understand cron, you'll know that `/var/spool/cron/crontabs/root` is the root user's crontab, which is how crons are scheduled in Linux.  This is the answer, and we can move on to number 4!

# Conclusion
Again, our initial filtering and a little knowledge of how Linux works is helping us breeze through these challenges.  In my conclusion for [Red Team Activity 2's Writeup](/blog/ritsec-ctf-2023/forensics/red-team-activity-2), I mentioned that you could see the red teamers adding persistence and doing other things.  Start to think about how you may want to go about preserving evidence on this server while also neutralizing the red team's ability to access or execute scripts.
