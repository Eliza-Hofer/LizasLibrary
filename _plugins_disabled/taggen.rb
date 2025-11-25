# _plugins/generate-tags.rb
module Jekyll
  class TagPageGenerator < Generator
    safe true

    TAGS = ["Cybersecurity", "Content Creation", "E-Waste Restoration", "Academics", "Personal Updates", "Miscellaneous"]

    def generate(site)
      TAGS.each do |tag|
        site.pages << TagPage.new(site, site.source, File.join('tags', tag.downcase.gsub(' ', '-')), tag)
      end
    end
  end

  class TagPage < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag.html')
      self.data['tag'] = tag
      self.data['title'] = "Posts tagged \"#{tag}\""
      self.data['exclude_from_nav'] = true
    end
  end
end

