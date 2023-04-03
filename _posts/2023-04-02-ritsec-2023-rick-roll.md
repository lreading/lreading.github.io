---
layout: post
title:  RITSEC 2023 - Web / Rick Roll
summary: 'Writeup for RITSEC 2023 "Rick Roll" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/web/rick-roll
usemathjax: true
---

# The Challenge
You are led to a website called that is literally just a rickroll.  There's a "don't sign in" button that takes you to the infamous video.  Props to the author for the amount of trolling here.

## Finding the Flag
Well, there isn't any obvious way of interacting with this website aside from the 2 static HTML pages.  So let's take a look at the source.  First, I'll look at `Don't.html`.  Right away, I see a lot of comments at the bottom of the page.  It seems to be the lyrics, and boy oh boy I'm getting RickRolled at this point.  I decided to scroll through them on a hunch, and I see a comment in the middle of the lyrics that says "It might be here!"
Scrolling down a bit more, I found this line:

![Partial Flag in HTML Comment](/assets/img/posts/ritsec-ctf-2023/rick-roll/comment-1.png 'Partial Flag')
<br /><br />
That looks like a partial flag if I've ever seen one!  Let's grab the entire source.

## Grabbing the Source
This site is small enough that you could just use curl or wget, but I found this nifty tool that does it for you. [https://websitedownloader.io](https://websitedownloader.io).  I can't verify they aren't spying on you or distributing malware or anything, I'm just saying I used it once and it worked fine.

After we get the source, we just need to scan through the files to find the other pieces of the flag.  This turned out to be pretty easy, as they were all comments, and I was using an IDE with syntax highlighting.  The instructions for the challenge were actually in one of the CSS files, [https://rickroll-web.challenges.ctf.ritsec.club/2.css](https://rickroll-web.challenges.ctf.ritsec.club/2.css)

![Instructions in CSS file](/assets/img/posts/ritsec-ctf-2023/rick-roll/css-instructions.png 'Instructions')

# Conclusion
When I first started finding the parts of the flags, there was some strange encoding issues where it wasn't rendering correctly in the dev tools.  I should have just downloaded the source to  begin with, and I would have avoided some guess and check work later.  This lesson may or may not repeat itself in another challenge...
