---
title: Sitemap
layout: base
permalink: /sitemap/
---

# Sitemap

## Pages
{%- for page in site.pages %}
  {%- if page.title and page.url != "/sitemap/" %}
- [{{ page.title }}]({{ page.url }})
  {%- endif %}
{%- endfor %}

## Blog
{%- for post in site.posts limit: 10 %}
- [{{ post.title }}]({{ post.url }})
{%- endfor %}

## Projects
{%- for project in site.projects %}
- [{{ project.title }}]({{ project.url }})
{%- endfor %}

## Gallery
{%- for item in site.gallery %}
- [{{ item.title }}]({{ item.url }})
{%- endfor %}

## Other
- [RSS Feed](/rss.xml)
