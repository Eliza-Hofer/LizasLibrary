#!/usr/bin/env ruby
# scripts/generate_tag_pages.rb
# Robust tag page generator:
# - supports tags as Array, as String ("Gem" or "Gem, Foo"), or nil
# - collects tags from posts and all collections
# - writes tags/<slug>/index.md with 'tagged_items' front matter

require 'fileutils'
require 'jekyll'
require 'set'
require 'yaml'
require 'time'

OUTPUT_DIR = "tags"
LAYOUT_NAME = "tag_page"
PERMALINK_BASE = "/tags"
SKIP_IF_MANUAL_EXISTS = true

def sanitize_slug(tag)
  s = tag.to_s.downcase.strip
  s = s.gsub(/[^\w\s-]/, '')   # remove non-word characters
  s = s.gsub(/\s+/, '-')       # spaces -> hyphens
  s = s.gsub(/-+/, '-')        # collapse multiples
  s = s.gsub(/\A-+|-+\z/, '')  # trim edges
  s
end

def normalize_tag_list(raw)
  return [] if raw.nil?
  if raw.is_a?(Array)
    raw.map { |t| t.to_s.strip }.reject(&:empty?)
  elsif raw.is_a?(String)
    # if comma separated, split; otherwise treat as single tag (trim)
    if raw.include?(',')
      raw.split(',').map { |t| t.to_s.strip }.reject(&:empty?)
    else
      [ raw.to_s.strip ].reject(&:empty?)
    end
  else
    []
  end
end

def ensure_dir(path); FileUtils.mkdir_p(path) unless Dir.exist?(path); end
def manual_page_exists?(base, slug)
  idx_md = File.join(base, OUTPUT_DIR, slug, 'index.md')
  idx_html = File.join(base, OUTPUT_DIR, slug, 'index.html')
  File.exist?(idx_md) || File.exist?(idx_html)
end

puts "Building site in memory..."
config = Jekyll.configuration({ 'source' => Dir.pwd, 'destination' => File.join(Dir.pwd, '_site_tmp') })
site = Jekyll::Site.new(config)
begin
  site.process
rescue => e
  STDERR.puts "Jekyll error: #{e.class}: #{e.message}"
  STDERR.puts e.backtrace.join("\n")
  exit 1
end

all_tags = Set.new
item_map = {}  # tag => array of item hashes

# helper to add an item for a tag
add_item = lambda do |tag, item|
  tag_s = tag.to_s
  all_tags.add(tag_s)
  item_map[tag_s] ||= []
  item_map[tag_s] << item
end

# collect from posts
if site.respond_to?(:posts) && site.posts.respond_to?(:docs)
  site.posts.docs.each do |p|
    tags = normalize_tag_list(p.data['tags'])
    tags.each do |t|
      add_item.call(t, {
        'title' => (p.data['title'] || p.data['basename']),
        'url' => (p.url || p.data['permalink'] || ""),
        'date' => (p.data['date'] ? p.data['date'].to_s : nil),
        'collection' => 'posts'
      })
    end
  end
end

# collect from all collections
if site.collections
  site.collections.each do |coll_name, coll|
    next unless coll.respond_to?(:docs)
    coll.docs.each do |doc|
      tags = normalize_tag_list(doc.data['tags'])
      tags.each do |t|
        add_item.call(t, {
          'title' => (doc.data['title'] || doc.data['basename']),
          'url' => (doc.url || doc.data['permalink'] || ""),
          'date' => (doc.data['date'] ? doc.data['date'].to_s : nil),
          'collection' => coll_name.to_s
        })
      end
    end
  end
end

puts "Found #{all_tags.size} tags: #{all_tags.to_a.join(', ')}"

ensure_dir(OUTPUT_DIR)

all_tags.to_a.sort.each do |tag|
  slug = sanitize_slug(tag)
  out_dir = File.join(OUTPUT_DIR, slug)
  out_file = File.join(out_dir, 'index.md')

  if SKIP_IF_MANUAL_EXISTS && manual_page_exists?(Dir.pwd, slug)
    puts "Skipping #{tag} (manual exists)"
    next
  end

  ensure_dir(out_dir)

  items = item_map[tag] || []
  # sort by date desc when available
  items.sort_by! do |it|
    if it['date'] && !it['date'].to_s.empty?
      begin
        -Time.parse(it['date']).to_i
      rescue
        0
      end
    else
      0
    end
  end

  front = {
    'layout' => LAYOUT_NAME,
    'title' => "Tag: #{tag}",
    'tag' => tag,
    'permalink' => File.join(PERMALINK_BASE, slug, '/'),
    'tagged_items' => items
  }

  File.open(out_file, 'w') do |f|
    f.puts front.to_yaml
    f.puts '---'
    f.puts "\n"
  end

  puts "Wrote #{out_file} (#{items.size} items)"
end

puts "Done. Review ./#{OUTPUT_DIR}/ and commit changes."

