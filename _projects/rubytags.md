---
layout: page
title: "TagGem"
permalink: /plugin-name/
nav_order: 4
tags: ["Ruby", "DevOps", "Automation", "Gem"]
 
---

# Building RubyTags: A Ruby Gem for Jekyll Tags

### Introduction

This project details the development of **[TagGem]**, a custom Ruby Gem designed to solve a critical efficiency problem within the Jekyll CMS. Instead of generating a tag page manually you can now add a list of tags into the program to have it auto-generate your tags on build. 

The initial challenge was making pages that did not get included in my main menu. Existing solutions were either too generic or introduced excessive dependencies . My goal was to create a **lightweight, platform-agnostic, and highly focused tool** that would allow developers to define tags on their Jekyll website with a single command. I realized that my problem was that my navigation looped over every page and added it to the menu. I solved this by adding to the program a line that tells the program. While the program is currently funcitonal I plan to clean up the project in the future and release it for other open source developers.

### Key Technologies Used

* **Language:** Ruby
* **Packaging:** RubyGems
* **Target Environment:** Jekyll CMS

