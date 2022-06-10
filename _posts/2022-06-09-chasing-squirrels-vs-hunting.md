---
layout: post
title:  Chasing Squirrels vs Hunting
summary: When are we wasting time, and when are we adding value?
author: leo
date: '2022-06-09 20:00:00 -0400'
category: security
thumbnail: /assets/img/posts/squirrel.jpg
include_thumbnail: true
keywords: security, blue-teaming
permalink: /blog/chasing-squirrels-vs-hunting/
usemathjax: true
---

# Chasing Squirrels vs Hunting
I spend most of my day being wrong about things.  I've not only accepted this, I've learned to embrace it.  When my assumptions are challenged or new information is presented, I'm able to learn and understand more.  In many ways, being wrong is a _beautiful_ thing. 

"Chasing squirrels" refers to spending time on something that is insignificant.  I have to wear a lot of hats at my job, and it's part of my responsibility to be spending time in ways that add value to the organization: chasing squirrels, by definition, does not add value.  

You can probably see the flaw in my logic: I shouldn't waste time chasing squirrels, AND I'm frequently wrong about things.  What if it isn't a squirrel I'm chasing?

## Story Time!
I realized that I didn't know a lot about a particular class of vulnerability, and I wanted to do better. I read some articles and cheat-sheets, then played a couple retired [HackTheBox](https://www.hackthebox.eu/) machines featuring this type of vulnerability.  (I have no affiliation to HTB, I just think it's an awesome learning tool!) I was excited about what I just learned, and set out on a mission to find this type of vulnerability at work.  

I had a "gut feeling" about a feature in the application so I started there.  I set a one hour time-limit for myself - if I didn't find anything after an hour, I would move on to my other tasks.  After about 45 minutes, I found evidence that the application was vulnerable to this type of attack. The evidence was pretty weak and the impact was insignificant, but it was a starting point.

At this point, I was thinking that this may be a "squirrel".  There were multiple compensating controls in place, and I couldn't do anything particularly malicious with the finding.  I decided to continue exploring it though: I was learning some neat things, and I had at least a _little_ evidence that something bigger may be hidden underneath.

After researching the compensating controls, I started theorizing potential bypasses.  A few hours later, I had a handful of unrelated vulnerabilities that, when chained together, allowed me to bypass all of them. At this point, I was able to polish my proof-of-concept and begin the process of working with our teams to get it remediated.

I won't be providing specific details, but there were at least 6 findings, including one that is in a third-party library.  This vulnerability was reported to the maintainers years ago, and was closed as "not an issue". Not having known CVEs in your dependencies does not mean "secure".  All in, my investigation took about 6 hours.  Attackers don't always work with the same time-frames that we defenders do: they can take as much time as they need to find an attack vector and exploit it. This is what makes it hard for me to know when I'm chasing squirrels vs _actually_ hunting.

## What Is a Squirrel?
I like to ask myself the following questions when I think I may be chasing a squirrel:
- Am I gaining knowledge/skills?
- Is this knowledge transferrable to other areas?
- Are my actions making things more secure?
- What is the impact if an attacker with more time was able to exploit this?

If you've answered "yes" to at least two of these questions, it's probably not a squirrel.  I tend to apply this to my own personal research as well.  Is it the right way?  Well... We've established my track record for being "right" about things, so probably not.  It has, however, been working well for me.  I find it's provided a great balance between getting my work done and advancing my skill-set/career. 

Even after all of that, yes, I sometimes chase squirrels.  It _is_ worth it to chase squirrels sometimes.  Feeling like you wasted your time on something helps you build your intuition.  Learn to be wrong, love to be wrong, and most importantly - act like a dog and chase a squirrel every now and then. You may never catch it, but you'll have fun while doing it!
