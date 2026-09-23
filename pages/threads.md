---
title: "Threads"
description: "Conversations, thoughts, half-ideas, things I am starting to explore."
permalink: /threads/
math: true
toc: true
---

# Threads

Conversations, thoughts, half-ideas, things I am starting to explore.

{% assign feedback_form = "https://docs.google.com/forms/d/e/1FAIpQLSeRD0Q9wYYZelAkRXEu2cCFN89-cvoAfOtyTY9vaz9-FUvYXQ/viewform?usp=pp_url&entry.2083454847=" %}
{% assign entries = site.threads | sort: "date" | reverse %}

{% for entry in entries %}
## {{ entry.title }}

{::nomarkdown}
{{ entry.content }}
{:/nomarkdown}

{% assign slug = entry.title | replace: ".", "" | slugify %}
{% assign feedback_target = site.url | append: "/threads/#" | append: slug %}
[push back on this entry (anonymous)]({{ feedback_form }}{{ feedback_target | url_encode }}){:target="_blank" rel="noopener noreferrer"}
{% endfor %}
