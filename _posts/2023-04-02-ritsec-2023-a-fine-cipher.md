---
layout: post
title:  RITSEC 2023 - Crypto / A Fine Cipher Writeup
summary: 'Writeup for RITSEC 2023 "A Fine Cipher" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/crypto/a-fine-cipher
usemathjax: true
---

# What kind of cipher is this?
I didn't recognize the format of the encrypted message that was provided, so I started with google.  I figured I could google the name of the challenge and that the Google Gods would steer me in the right direction....
<br /><br />
![Google Search Results for "A Fine Cipher"](/assets/img/posts/ritsec-ctf-2023/a-fine-cipher/google-results.png "Google Search Results")
<br /><br />
Yep, google did its thing for me!


# How do we crack it?
I'll be honest, I didn't really do a lot of research here trying to understand how to manually crack it.  More googling showed that it's known to be pretty easily brute-forced.  I love the [decode.fr](https://www.decode.fr/) site for these types of things.  They do have an [affine cipher brute-forcing tool](https://www.decode.fr/affine-cipher/).  I plugged the input into that, and it presented a wide variety of results based on the values of A/B.  The first one it found looked to be the flag:
<br /><br />
![decode.fr results](/assets/img/posts/ritsec-ctf-2023/a-fine-cipher/bfed.png "Results from decode.fr's brute-force tool")


# Conclusion
I didn't do myself any favors by plugging this into a tool without learning more about it, but it does seem that like this is a very "CTF" type of challenge, as I haven't ever seen AFFine Ciphers used in the wild.  While it's possible, it's extremely uncommon and trivial to crack.
