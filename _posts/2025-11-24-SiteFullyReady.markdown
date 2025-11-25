---
layout: post
title: "The New Site is Live: Exploring My Technical Home"
author: Your Name
date: 2025-11-25 18:07:27 -0500
categories: [Personal Updates, Development]
tags: [Jekyll, Ruby, Open-Source, Personal Updates]
---

Hey everyone!

Welcome to the new digital home for all my projects and thoughts. I've been wanting a consolidated space to share everything—from my deep dives into **Cybersecurity** to the latest steps in my **E-Waste Restoration** hobby and, of course, updates on my **Open-Source** work. This site is that space!

It's built with **Jekyll**, which gives me full control over the presentation, performance, and structure. But what makes it truly tick is the custom engineering that went into the core functionality.

---

## 🧭 Navigating the Core Features

I designed this site to be fast, minimal, and, most importantly, easy to explore.

### 1. Projects and Posts Integration

I use Jekyll's built-in collections to separate my content:
* **Posts:** This is where you'll find long-form articles, tutorials, and deep technical dives.
* **Projects:** These are more focused entries detailing specific technical endeavors, like hardware builds or major code contributions.

The entire site is structured so that both types of content are searchable and linked together seamlessly.

### 2. The Custom Tagging Engine 💎

This is the most powerful feature under the hood. Unlike standard Jekyll sites, which often require manual lists for tags, I built a custom **Jekyll Generator plugin** in Ruby.

This plugin ensures that tagging is dynamic and automatic:
* I only have to add a tag to a post's front matter (e.g., `tags: [Python, Cybersecurity]`).
* During the site build, the Ruby script scans *all* my content, collects every unique tag, and automatically **generates a complete, separate tag page** for each one (e.g., `/tags/python/`).
* This page automatically includes **both** the relevant Posts and Projects, giving you a comprehensive view of everything I've done on a given topic.

This engine means less administrative work for me and a better, more complete browsing experience for you!

### 3. Clean and Accessible Design

You might notice the design is clean, fast, and uses a focused color palette. The CSS is lightweight, ensuring quick load times, which is always a priority for me. The entire layout is structured to keep the focus purely on the content, whether you're reading a complex write-up or browsing a project card.

---

## ➡️ What's Next?

Now that the foundation is solid, expect a lot more content. I'll be sharing detailed project logs, starting with a comprehensive write-up on my latest **E-Waste Restoration**, and a deep-dive technical post on the Python library I just published.

Thanks for checking out the site. Feel free to explore using the tags index, and please let me know what you think!
