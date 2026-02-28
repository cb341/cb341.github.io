---
title: "Projects"
permalink: /projects/
---

# Projects

A collection of personal projects I've worked on.

_There are many more to be documented here. [Check out my GitHub](https://github.com/cb341) for more projects in the meantime._

{%- for project in site.projects %}

## [{{ project.title }}]({{ project.url }})

{{ project.description }}

{%- endfor %}
