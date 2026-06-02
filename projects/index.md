---
title: "Projects"
permalink: /projects/
layout: base
---

# Projects

Things I built, broke, rewrote, or kept around long enough to document.

More lives in [GitHub repositories](https://github.com/cb341?tab=repositories&q=&type=source&language=&sort=).

{%- for project in site.projects %}
<p>
  <a href="{{ project.url }}"><b>{{ project.title }}</b></a><br>
  {{ project.description }}
</p>
{%- endfor %}
