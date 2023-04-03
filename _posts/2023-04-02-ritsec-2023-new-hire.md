---
layout: post
title:  RITSEC 2023 - Misc / New Hire
summary: 'Writeup for RITSEC 2023 "New Hire" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/misc/new-hire
usemathjax: true
---

# Just For Funsies
You are given a [LinkedIn]() profile, and told the following:
> We're thinking of hiring this new guy, what do you think of his skills?

Well, we know that LinkedIn has a "Skills" section, let's take a look!
<br /><br />
![linkedin skills](/assets/img/posts/ritsec-ctf-2023/new-hire/skills.png "LinkedIn Skills")
<br />
<br />
The first thing I noticed was that the first two skills started with `R` and then `S`.  Given that it's a RITSEC CTF and the flag format is typically `RS{<flag>}`, it's safe to assume the flag was a combination of the first letter of each skill, or all of the capitalized letters.

## First Letter of Each Skill
This spelled `RS{NOTEUR}`.  Flags usually have a bit more context to them, so let's try all capitalized letters.

## Capitalized Letters
This one spelled out `RS{NOOTSECURE}`, which seemed like a more realistic flag.  I submitted the flag and that was it!

# Conclusion
I like the idea of this challenge because it emphasizes the importance of OPsec and what you should and shouldn't share online.  With that said, it just wasn't my cup to tea so I decided to focus on the web challenges more.
