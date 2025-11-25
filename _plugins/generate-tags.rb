require 'set'
require 'fileutils'
require 'jekyll'

module Jekyll
  
  class TagPageGenerator < Generator
    safe true
    priority :low

    def self.sanitize_slug(tag)
      s = tag.to_s.downcase.strip
      s = s.gsub(/[^\w\s-]/, '')
      s = s.gsub(/\s+/, '-')
      s = s.gsub(/-+/, '-')
      s = s.gsub(/\A-+|-+\z/, '')
      s
    end

    def generate(site)
      all_tags = Set.new
      
      site.posts.docs.each do |post|
        if post.data['tags'].is_a?(Array)
          post.data['tags'].each { |tag| all_tags.add(tag) } 
        end
      end
      
      site.collections['projects'].docs.each do |project|
        if project.data['tags'].is_a?(Array)
          project.data['tags'].each { |tag| all_tags.add(tag) } 
        end
      end

      all_tags.each do |tag|
        slug = TagPageGenerator.sanitize_slug(tag)
        dir = File.join('tags', slug)

        if manual_exists?(site.source, dir)
          Jekyll.logger.debug "TagPageGenerator:", "Manual tag page exists for #{tag} -> skipping generator"
          next
        end

        site.pages << TagPage.new(site, site.source, dir, tag)
      end
    end

    private

    def manual_exists?(base, dir)
      idx_html = File.join(base, dir, 'index.html')
      idx_md   = File.join(base, dir, 'index.md')
      idx_markdown = File.join(base, dir, 'index.markdown')
      File.exist?(idx_html) || File.exist?(idx_md) || File.exist?(idx_markdown)
    end
  end

  class TagPage < Jekyll::Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      process(@name)
      
      read_yaml(File.join(base, '_layouts'), 'tag_page.html') 

      slug = TagPageGenerator.sanitize_slug(tag)

      self.data['tag']   = tag
      self.data['title'] = "Content Tagged: #{tag}"
      self.data['layout'] = 'tag_page' 
      
      self.data['tagged_content'] = site.posts.docs.select do |p| 
        p.data['tags'].is_a?(Array) && p.data['tags'].include?(tag)
      end + site.collections['projects'].docs.select do |p|
        p.data['tags'].is_a?(Array) && p.data['tags'].include?(tag)
      end
      
      self.data['permalink'] = File.join('/', 'tags', slug, '/')

      self.data['exclude_from_nav'] = true
      self.data['sitemap'] = false
    end
  end
end
