---
layout: post
title:  RITSEC 2023 - Misc / Connection Terminated
summary: 'Writeup for RITSEC 2023 "Connection Terminated" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/misc/connection-terminated
usemathjax: true
---

# Full Disclosure
I got _close_ to finding the flag here, but never got it across the line.  I will note where I got to and what I missed.  You can view the [official writeup here](https://gitlab.ritsec.cloud/competitions/ctf-2023-public/-/blob/master/MISC/Connection_Terminated/Connection_Terminated.md)

# The Prompt
```
[CONNECTION START]
Unknown: "DUDE YOU... [STATIC] BELIEVE WHERE AND WHAT WE ARE TRANSMITTING FROM!"
Walter: "Your connection sounds fuzzy, theres no way you are using an antenna."
Unknown: "WE MADE OUR OWN USING TH... [STATIC]"
Walter: "I'm losing you, what the hell are you talking about?"
Unkown: "THERE IS NEWS REPORTING ABOUT IT, RIT LET US USE... [STATIC] THE ANTENNA."
Walter: "Dog what are you saying, you're on the news? Where are you?!"
Unknown: "YEAH LOOK IT UP, OUR LOCATION IS... [STATIC].[STATIC].[STATIC]"
Walter: "What kind of location uses three words?"
Unknown: "I SEE MUNSON"
Walter: "Wha..."
[CONNECTION TERMINATED]
Walter: "I need to try and find his location and flag him down, that made no sense."
```

## Three Part Location?
That was a great question, what kind of location uses three words?  Let's google it.  Oh, `what3words` is a thing?  Neat!  That must be it.  What else did the prompt tell us?

## I SEE MUNSON
I'm starting to this this may make more sense for RIT students, as [David Munson](https://www.rit.edu/directory/dcmpro-david-munson) is the current President of the Rochester Institute of Technology (RIT).  The location is probably going to be at the university (which makes sense for a CTF hosted by a university!) Let's move on.

## NEWS
Well, this is where I screwed up.  I searched for "RIT antenna news" and landed on an article about a [transparent antenna system to provide outdoor WiFi to museum guests](https://www.rit.edu/imagine/exhibits/transparent-antenna-system-provide-outdoor-wifi-museum-guests).  ....this is objectively cool. Props, RIT. I recommend giving it a read.  I was sure I found the right thing, but I was wrong.  Looking into it more, I found the building it was in and used `what3words` to get the address and submitted the flag, no dice.

## I'm Stuck
I tried a few other locations for RIT, and none of them seemed to work.  RIT doesn't appear to be a _small_ campus (I've never been, just looking at maps), so it would have been hard to try all possible locations.  This is where I gave up.  

# Conclusion
I shouldn't have given up when I did.  I have followed the clues correctly, but my search for the antenna overlooked the [Hackaday Artile](https://hackaday.com/2023/03/23/enormous-metal-sculpture-becomes-an-antenna/) that would have given me the correct location.  In the future, when I get stuck on a wrong answer, I should retrace my steps and double check my previous assumptions.
