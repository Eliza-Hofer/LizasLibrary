#!/usr/bin/env ruby
# scripts/generate_tag_pages.rb
require 'fileutils'
require 'jekyll'
require 'set'
require 'yaml'

# helper (same slug logic)
def sanitize_slug(tag)
  s = tag.to_s.downcase.strip
  s = s.gsub(/[^\w\s-]/, '')
  s = s.gsub(/\s+/, '-')
  s = s.gsub(/-+/, '-')
  s = s.gsub(/\A-+|-+\z/, '')
  s
end

config = Jekyll.configuration({ 'source' => Dir.pwd, 'destination' => File.join(Dir.pwd, '_site_tmp') })
site = Jekyll::Site.new(config)
site.process

tags = Set.new
# collect tags from posts
if site.posts.respond_to?(:docs)
  site.posts.docs.each do |post|
    if post.data['tags'].is_a?(Array)
      post.data['tags'].each { |t| tags.add(t) }
    end
  end
end

# collect tags from projects collection if present
if site.collections && site.collections['projects']
  site.collections['projects'].docs.each do |proj|
    if proj.data['tags'].is_a?(Array)
      proj.data['tags'].each { |t| tags.add(t) }
    end
  end
end

puts "Found #{tags.size} tags: #{tags.to_a.join(', ')}"

tags.each do |tag|
  slug = sanitize_slug(tag)
  dir = File.join('tag', slug) # earlier we suggested /tag/ ; previously we used /tags/ — choose the one your site expects
  # NOTE: you used 'tags' plural in plugin; keep consistent. I'll use 'tag' here because many sites use /tag/<name>/
  # If you want 'tags', change dir = File.join('tags', slug)

  dir = File.join('tags', slug)  # use plural 'tags' to match plugin above
  FileUtils.mkdir_p(dir)

  file = File.join(dir, 'index.md')
  front = {
    'layout' => 'tag_page',
    'title'  => "Tag: #{tag}",
    'tag'    => tag,
    'permalink' => "/tags/#{slug}/"
  }

  File.open(file, 'w') do |f|
    f.puts front.to_yaml
    f.puts '---'
    f.puts "\n" # body blank; layout will render using page.tag
  end

  puts "Wrote #{file}"
end

puts "Done. Review tag/ files, then git add, commit and push them."

