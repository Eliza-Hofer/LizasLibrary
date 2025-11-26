#!/usr/bin/env ruby
# scripts/debug_tags.rb
require 'jekyll'
require 'yaml'
require 'set'
require 'pp'

config = Jekyll.configuration({ 'source' => Dir.pwd, 'destination' => File.join(Dir.pwd, '_site_tmp') })
site = Jekyll::Site.new(config)

begin
  site.process
rescue => e
  STDERR.puts "Jekyll build failed: #{e.class}: #{e.message}"
  STDERR.puts e.backtrace.join("\n")
  exit 1
end

puts "=== Projects collection existence check ==="
if site.collections && site.collections['projects']
  coll = site.collections['projects']
  puts "Found collection 'projects' with #{coll.docs.size} docs."
  coll.docs.each_with_index do |doc, i|
    puts "\n---- project ##{i+1} ----"
    puts "path: #{doc.path}"
    puts "relative_path: #{doc.relative_path}"
    puts "basename: #{doc.basename}"
    puts "title: #{doc.data['title'].inspect}"
    puts "raw tags field: #{doc.data['tags'].inspect}"
    # Normalize tags similar to generator logic
    tags = []
    raw = doc.data['tags']
    if raw.is_a?(Array)
      tags = raw.map(&:to_s)
    elsif raw.is_a?(String)
      # split on commas or whitespace
      if raw.include?(',')
        tags = raw.split(',').map(&:strip)
      else
        tags = [ raw.strip ]
      end
    else
      tags = []
    end
    puts "normalized tags => #{tags.inspect}"
    puts "url: #{doc.url.inspect}"
  end
else
  puts "No 'projects' collection found. site.collections keys: #{site.collections.keys.inspect}"
end

# show site.tags counts too
if site.respond_to?(:tags)
  puts "\n=== site.tags summary ==="
  site.tags.each do |tag, posts|
    puts "#{tag.inspect} => #{posts.size}"
  end
else
  puts "\n=== site.tags not present ==="
end

