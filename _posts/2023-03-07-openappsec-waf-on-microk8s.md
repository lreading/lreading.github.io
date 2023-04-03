---
layout: post
title:  Openappsec on Microk8s
summary: How to install Openappsec WAF on Microk8s
author: leo
date: '2023-03-07 00:00:00 -0400'
category: security
thumbnail: /assets/img/posts/pexels-erik-scheel-105194.jpg
include_thumbnail: false
keywords: security, open source, waf
permalink: /blog/openappsec-on-microk8s/
usemathjax: true
---

# TLDR
This expirement didn't work out, it appears to not work _as of the time of writing_.  Always check with the source, as things could have changed!


# What are these words?
Openappsec is a Web Application Firewall (WAF) that is still in beta, and Microk8s is a lightweight kubernetes platform that isn't _often_ used for production deployments.  I am lazy and rely on microk8s for little VMs to do lots of work for me.  I also wanted to play with the new shiny toy on the market for WAFs. So while this is potentially an unusual scenario, it's very possible that there are others exploring this combination for testing.

Openappsec looks like a very promising product, and they even have some nice little install utilities.  Unfortunately, those utilities do not work (yet) on microk8s.

# Note on WAFs
WAFs can be a good part of an overall security program, but they are definitely not a silver bullet.  From my experience, they are most useful for preventing a lot of the botnet activity, and they may annoy your drive-by script-kiddy _just enough_ to convince them to move onto the next target.  Just about any rule you can configure in a WAF can be bypassed by a good enough attacker.

# Installing Openappsec on Microk8s
## Prerequisites
- jq
- yq
- helm
- microk8s
- microk8s ingress addon enabled (you may also want DNS or other addons)

## Modifying the quick-start script:
From [Openappsec's Documentation](https://docs.openappsec.io/getting-started/start-with-kubernetes/install-using-interactive-cli-tool-ingress-nginx), you can download their setup script and execute it to install openappsec on an existing kubernetes cluster with an nginx ingress.

Microk8s uses nginx as their ingress controller, but for whatever reason, the class name is not `nginx`, it's `public`.  I haven't done enough research to understand why.

If you run the script from https://downloads.openappsec.io/open-appsec-k8s-install, you will get an error telling you that your ingress is not currently supported.

If you modify the script (at the time of writing, it's on line 185), you can tell it to continue with your microk8s ingress.  Change the grep to be the following:
```
if ! grep -qE "ingressClassName: (nginx|public)" ingress.yaml.tmp  ; then
```

Run this again, and it should be good to go!

# Closing Thoughts
I am writing this before I forget, and haven't really played with openappsec yet.  I'm not even 100% confident that it's going to work perfectly with microk8s, though I do see some events in the logs!  Hopefully I will have more time to continue evaluating it and can write up a more detailed review at a later date.