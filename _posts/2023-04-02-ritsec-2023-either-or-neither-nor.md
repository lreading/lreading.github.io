---
layout: post
title:  RITSEC 2023 - Crypto / Either or Neither nor
summary: 'Writeup for RITSEC 2023 "Either or Neither nor" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/crypto/either-or-neither-nor
usemathjax: true
---

# The Prompt
You are given a page that links to a python snippet.  This snippet looks to encrypt a string using xor.
```python
#! /usr/bin/env python

flag = "XXXXXXXXXXXXXXXXXXXXX"
enc_flag = [91,241,101,166,85,192,87,188,110,164,99,152,98,252,34,152,117,164,99,162,107]

key = [0, 0, 0, 0]
KEY_LEN = 4

# Encrypt the flag
for idx, c in enumerate(flag):
    enc_flag = ord(c) ^ key[idx % len(key)]
```

## What do we have?
We know that xor encryption can be cracked easily in most cases.  Additionally, we know we have the encoded flag, and key length. We need to derive the flag.

## Brute Force or Code?
Realistically, I should have written my own script to do this.  However, I was lazy and went back to my good friend, [decode.fr](https://www.dcode.fr/xor-cipher), specifically the XOR cipher tool.

## Decrypting
If you copy _just the values_ of the encoded flag (without the brackets) and paste it into the "Text to be XORed" field, it will audit detect the text type is **Decimal Extended ASCII [0-255]**.  Perfect!  
Additionally, there's a setting for "Knowing the key size (in bytes)".  Well, we know that's 4, so let's put that in.

## Results
Woah, that's a lot of results.  That said, the first handful all have the open-brace character `{`.  This tells me that the flag is already formatted for us.  The prompt also tells us that the flag is in the format `MetaCTF{<flag>}`.  Let's search the page for `MetaCTF`.  There's only 1 hit, and it's our flag!
<br />
![Decrypted flag](/assets/img/posts/ritsec-ctf-2023/either-or-neither-nor/decrypted.png "Decrypted Flag")

# Conclusion
This was another case of me being lazy instead of truly understanding how to reverse engineer these crypto algos. I got the flag, but I really should have spent the time to understand how it worked more.
