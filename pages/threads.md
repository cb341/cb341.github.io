---
title: "Threads"
description: "Conversations, thoughts, half-ideas, things I am starting to explore."
permalink: /threads/
math: true
---

# Threads

Conversations, thoughts, half-ideas, things I am starting to explore.

{% assign feedback_form = "https://docs.google.com/forms/d/e/1FAIpQLSeRD0Q9wYYZelAkRXEu2cCFN89-cvoAfOtyTY9vaz9-FUvYXQ/viewform?usp=pp_url&entry.2083454847=" %}
{% assign entries = site.threads | sort: "date" | reverse %}

<style>
.threads-toc { font-size: .9em; border-left: 3px solid var(--line, #e6e6e2); padding-left: 1em; }
.threads-toc ul { list-style: none; padding: 0; margin: .3em 0 .8em; }
.threads-toc li { margin: .15em 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.threads-toc .month { font-weight: bold; }
.threads-toc .day { font-variant-numeric: tabular-nums; display: inline-block; min-width: 2ch; margin-right: .5ch; }
</style>

{% assign months = entries | group_by_exp: "entry", "entry.date | date: '%B %Y'" %}
<nav class="threads-toc" aria-label="Entry index">
{%- for month in months %}
  <span class="month">{{ month.name }}</span>
  <ul>
  {%- for entry in month.items %}
    {%- assign slug = entry.title | replace: ".", "" | slugify %}
    {%- assign teaser = entry.content | strip_html | normalize_whitespace | truncatewords: 9, "" %}
    {%- assign last_char = teaser | slice: -1, 1 %}
    {%- if last_char == "." or last_char == "," or last_char == ";" or last_char == ":" %}
      {%- assign trimmed_length = teaser | size | minus: 1 %}
      {%- assign teaser = teaser | slice: 0, trimmed_length %}
    {%- endif %}
    <li><a class="day" href="#{{ slug }}" title="{{ entry.title }}">{{ entry.date | date: "%d" }}</a> {{ teaser | escape }}...</li>
  {%- endfor %}
  </ul>
{%- endfor %}
</nav>
{% for entry in entries %}
## {{ entry.title }}

{::nomarkdown}
{{ entry.content }}
{:/nomarkdown}

{% assign slug = entry.title | replace: ".", "" | slugify %}
{% assign feedback_target = site.url | append: "/threads/#" | append: slug %}
[push back on this entry (anonymous)]({{ feedback_form }}{{ feedback_target | url_encode }}){:target="_blank" rel="noopener noreferrer"}
{% endfor %}
