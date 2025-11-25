module Jekyll
  class TagPageGenerator < Generator
    safe true
    TAGS = ["Cybersecurity", "Content Creation", "E-Waste Restoration", "Academics", "Personal Updates", "Miscellaneous"]

    def generate(site)
      TAGS.each do |tag|
        slug = tag.downcase.gsub(' ', '-')
        site.pages << TagPage.new(site, site.source, File.join('tags', slug), tag)
      end
    end
  end

  class TagPage < Jekyll::Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'tag.html')

      self.data['tag'] = tag
      self.data['title'] = "Posts tagged \"#{tag}\""
      
      self.data['sitemap'] = false 
    end
  end
end
