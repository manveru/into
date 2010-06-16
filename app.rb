require 'rdiscount'
require 'innate'
require 'find'
require 'nokogiri'

module Into
  extend Innate::Traited

  class Articles
    include Innate::Node
    map '/'

    layout('default'){|name, wish| wish != "atom" }
    provide :html, engine: :Etanni
    provide :atom, engine: :Etanni, type: 'application/xml'

    def index(slug = nil)
      if article = Article[slug]
        render_view(:article, article: article)
      else
        render_view(:articles, articles: Article.first(10))
      end
    end
  end

  class Article
    extend Enumerable

    def self.each(&block)
      block_given? or return enum_for(__method__)

      Find.find 'articles' do |path|
        yield new(path) if File.file?(path)
      end
    end

    def self.[](slug)
      find{|article| article.slug == slug }
    end

    attr_reader :content, :path

    def initialize(path)
      all = File.read(path)
      head, tail = all.split("\n\n", 2)

      @path = path
      @head = {}
      @content = RDiscount.new(
        tail,
        :autolink, :safelink, :generate_toc, :smart
      )

      head.each_line do |line|
        key, value = line.strip.split(/\s*:\s*/, 2)
        self[key] = value
      end
    end

    def to_html
      content.to_html
    end

    def [](key)
      @head[key.to_s]
    end

    def []=(key, value)
      @head[key.to_s] = value
    end

    def summary
      Nokogiri::HTML(to_html).at(:p).inner_html
    end

    def slug
      File.basename(path, File.extname(path))
    end
    alias href slug

    def url
      Into.trait[:url]
    end

    def date
      Time.strptime(self[:date], '%Y-%m-%d')
    end

    def datetime
      date.strftime('%Y-%m-%d')
    end

    def showtime
      Into.trait[:date][date]
    end
  end
end
