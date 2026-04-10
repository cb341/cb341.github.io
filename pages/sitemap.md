---
title: Sitemap
layout: base
permalink: /sitemap/
---

# Sitemap

## Pages
- [Home](/)
{%- for page in site.pages %}
  {%- if page.title %}
- [{{ page.title }}]({{ page.url }})
  {%- endif %}
{%- endfor %}

## Blog
- [Latest Posts](/)
{%- for post in site.posts limit: 10 %}
- [{{ post.title }}]({{ post.url }})
{%- endfor %}
- [View all posts](/)

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
