---
layout: page
title: "Welcome to Liza's Library 📖"
permalink: /
nav_order: 1
---

<section id="intro">
  <div class="intro-container">
    <div class="intro-text">
      <h1>Hello, I’m Eliza </h1>
      <p>Welcome to my personal library and portfolio. Here I share my projects, experiments, and what I’m currently exploring in tech, security, and content creation.</p>
    </div>
    <div class="intro-image">
      <img src="{{ '/media/me2.jpg' | relative_url }}" alt="A professional photo of Eliza" style="width: 200px; height: 200px; border-radius: 50%; object-fit: cover;">
    </div>
  </div>
</section>

<section id="what-im-doing-now">
  <h2>What I’m Doing Now</h2>
  <ul>
    {% for post in site.posts %}
      <li>
        <strong><a href="{{ post.url | relative_url }}">{{ post.title }}</a></strong> — 
        <em>{{ post.date | date: "%B %-d, %Y" }}</em>
        <p>{{ post.excerpt | strip_html | truncate: 150 }}</p>
      </li>
    {% endfor %}
  </ul>
</section>
