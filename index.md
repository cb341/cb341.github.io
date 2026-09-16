---
title: "cb341.dev"
description: "Writing, projects, studying, visual scraps, and notes."
permalink: /
---

# cb341.dev

Writing, projects, studying, visual scraps, and notes.

- [Blog](/blog/) is for longer writing.
- [Threads](/threads/) is for loose thoughts and fragments.
- [Projects](/projects/) is for things I built.
- [Gallery](/gallery/) is for visual leftovers.
- [Quartz](https://quartz.cb341.dev/) is for studying and notes.

## Currently

Following Richard Behiel and [gwern.net](https://gwern.net/me).

Learning chess by playing slowly enough to see why I lose. Building [chess-widget](/projects/chess-widget/) to capture the games, annotations, and mistakes in a small static replay widget.

Also reading *99 Variations on a Proof*.

## Recent Writing

{%- for post in site.posts limit: 5 %}
- {{ post.date | date: site.date_format }}: [{{ post.title }}]({{ post.url }})
{%- endfor %}
