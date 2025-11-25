---
layout: page
title: "Projects"
permalink: /projects/
nav_order: 4
---

<div class="project-grid">
{% for project in site.projects %}
  {% assign project_link = project.external_link | default: project.url %}

  <div class="project-card">
    <a href="{{ project_link | relative_url }}">
      {% if project.thumbnail %}
        <img src="{{ project.thumbnail | relative_url }}" alt="{{ project.title }} thumbnail">
      {% endif %}
      <h2>{{ project.title }}</h2>
      <p>{{ project.excerpt | strip_html | truncate: 150 }}</p>
    </a>

    {% if project.tags %}
      <p><strong>Tags:</strong>
        {% for tag in project.tags %}
          {% assign tag_slug = tag | downcase | replace: ' ', '-' %}
          {% assign tag_url = '/tags/' | append: tag_slug | append: '/' %}
          <a href="{{ tag_url | relative_url }}">{{ tag }}</a>{% if forloop.last == false %}, {% endif %}
        {% endfor %}
      </p>
    {% endif %}
  </div>

{% endfor %}
</div>
