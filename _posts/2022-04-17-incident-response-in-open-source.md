---
layout: post
title:  Incident Response in Open Source
summary: How do we handle Incident Response in Open Source?
author: leo
date: '2022-04-17 20:00:00 -0400'
category: security
thumbnail: /assets/img/posts/iceberg.png
include_thumbnail: true
keywords: security, open source, incident, response
permalink: /blog/incident-response-in-open-source/
usemathjax: true
---

A part of my current day job is responding to security incidents.  In my free time, I contribute to some open-source work, namely [OWASP Threat Dragon](https://www.github.com/owasp/threat-dragon).  Threat Dragon hosts a demo instance on a small Heroku plan so that people can see it before going through the effort of downloading it or setting up a self-hosted instance. 

## The Incident
Heroku had a pretty serious [security incident](https://status.heroku.com/incidents/2413).  I received an email about this late at night, Friday, on a holiday weekend.  There weren't many details at the time, so I pinged Threat Dragon's other maintainer to notify him as well.  The next morning, more details were available, and it appeared that Threat Dragon was not impacted by this incident.  By Sunday night, I had some time to truly investigate and take additional proactive/corrective action to ensure the safety and security of our community.  

Heroku is owned by Salesforce, and the Salesforce security team did a wonderful job of handling this incident.  I love that they notified all of their customers once they were aware of such a serious incident.  Additionally, the writeup and level of detail on their public status page was wonderful. They provided clear steps to identify if you were impacted as well as how to search for indicators of compromise. This truly shows the maturity of their security/incident response teams.  I think it's worth noting that it was handled well, and the intent of this article is not to criticize the handling of the incident.

## Am I an Open-Source Incident Responder?
I'm used to responding to incidents that involve the company I work for, and do so according to their policies, procedures and reporting structure.  It's pretty common to have a [Security Policy](https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository) in open-source projects, but it doesn't typically cover incident response: Who is responsible, how/when is it reported, what tools/processes are at our disposal, etc.  This isn't scalable or even attainable for a community of volunteers. But does this mean we shouldn't have _any_ kind of incident response process?  

If my day-job had a potential security incident of this magnitude, I would have been working all weekend (or at least until it was remediated).  Open source isn't my full-time job, so I find myself less willing to give up my family/social commitments.  To be clear: I take the security of projects I contribute to seriously - I just don't feel obligated to immediately respond in the same way that I do with my full-time job. When I had some free time that Sunday night, I really dug in and found myself falling into my "incident response" groove.  It felt natural, and it felt like the right thing to do.

I felt conflicted for putting this off for a couple days while I spent time with my family.  As a maintainer, I _am responsible_ for the security of the project. The community contributions are outstanding, and often times include security updates. My role as a maintainer isn't to be the sole security engineer, but that doesn't mean I'm not _responsible_ for the security. The community trusts Threat Dragon, and we need to continue to actively earn that trust. I decided that this would be a priority for me when I had free-time to work on it, as opposed to _making_ the time.  This felt like a reasonable compromise for me, though I'm curious how others would feel about this.

## Who is this for?
I don't think that every open-source project really needs incident response.  A project would probably need one of the following to see any benefit:
- Publicly hosted instance/service
- Collection/processing of any data, with an emphasis on PII
- Auth tokens / auth mechanisms (even simple logins, users do re-use passwords!)

We've come a long way with responsible disclosure and timely remediation, especially in the open-source communities.  For projects where incident response may be appropriate, this could be a great way of building trust in your community as well as showing a strong commitment to the security of the project. 

## What Are You Proposing?
I have already [proposed this](https://github.com/OWASP/threat-dragon/issues/419) to the Threat Dragon community, and am curious what the feedback will be.  This will be centered around GitHub's features specifically, but could be easily adapted to any source control or ticketing system.

#### Incidents vs Vulnerabilities
For this discussion, I consider Incidents as a security weakness that has been exploited, such as a data breach.  This often centers around infrastructure and data. Vulnerabilities are bugs in first/third-party software which makes the code vulnerable to attack/exploitation. 

#### Incident Response
- Repositories / organizations should define a tag to be used for issues that describe security incidents
- An issue should be created with the incident tag **only after it does not increase risk for the community to discuss it publicly**
- Include the following in the issue:
  - TLDR
    - Not everyone will want to read the whole write-up.  This should tell users if they need to take action, or how to quickly determine if they're impacted
  - Summary
    - A high-level overview of what the issue was, who was impacted, and the duration of the incident
  - Timeline
    - A timeline of events starting with incident discovery, what steps were taken to investigate, and any corrective action
  - References
    - Include helpful references/resources
  - Evidence (Optional)
    - Include screenshots or evidence, but *only if it does not contain user data or secrets*
- The issue should be pinned until it is no longer relevant to the community or at least 3 days after it is resolved

#### Why?
Everyone _claims_ that they take security seriously, but words are cheap.  Let's have our actions do the talking.  This is a level of transparency that may be new or even uncomfortable for some.  There are compliance/legal reasons as to why corporations may not share this type of information, or even pressure from the c-suite / board.  In open-source, we do not operate within those constraints.  Our community is our board of trustees, and I've heard them clearly articulate that they want transparency and better security.  Publicly handling real or potential incidents is a step toward that goal, and if adopted in open-source, could eventually influence corporations.

## How is This Different From GitHub's Security Advisories?
[GitHub's security advisories](https://docs.github.com/en/code-security/repository-security-advisories/about-coordinated-disclosure-of-security-vulnerabilities#about-reporting-and-disclosing-vulnerabilities-in-projects-on-github) do a great job of sharing vulnerabilities that existed in different versions of software. This does not cover transient incidents involving upstream providers, like the example above.  I do understand that what I'm discussing is an edge-case, and may not be helpful for all projects either!  I also feel very strongly that we should have a process in place to guide us when it does happen, and ensure we are prepared.

## Conclusion
Unless an open-source project has a large company supporting it, there will likely never be an "incident response team" on standby.  That doesn't mean we can't do better with transparently handling potential/real security incidents in open-source.  We should promote a security culture where end-users are aware of and in control of their data, privacy, and security.  By being transparent with how these situations are handled, we will benefit from the collective knowledge of the community and develop better processes and controls.

I don't proclaim to be the most knowledgeable security practitioner out there: I'm still learning. Maybe this isn't the way forward, maybe there are _better_ ways of doing this - what's important is that it's discussed openly.  My hope is that one day, as a community, we come to a consensus of how to best handle security incidents for open-source projects.  

If you contribute to an open-source project, consider what you might do to help investigate a potential security incident - would this type of incident handling be beneficial for your community?  If you have any thoughts or want to follow the discussion, swing by the [issue on Threat Dragon's GitHub](https://github.com/OWASP/threat-dragon/issues/419) to discuss it!