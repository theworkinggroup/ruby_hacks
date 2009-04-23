module RubyHacks
end

class Array
  def to_h(*seeds, &block)
    case (seeds.length)
    when 0:
      if (block_given?)
        inject({ }) do |h, v|
          h[v] = yield(v)
          h
        end
      else
        inject({ }) do |h, v|
          h[v] = true
          h
        end
      end
    else
      seed = seeds.first
      inject({ }) do |h, v|
        seed = yield(seed, v) if (block_given?)
        h[v] = seed
        h
      end
    end
  end
end

class Hash
  def dig(*path)
    path.inject(self) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end
end

class String::Random < String
  RANDOM_LETTERS = [ ('a'..'z'), ('A'..'Z'), ('0'..'9') ].collect { |c| c.collect }.flatten.freeze
  
  def initialize(length = 12)
    super((1..length).collect { RANDOM_LETTERS.rand }.to_s)
  end
end

class String::HtmlSafe < String
  HTML_ENTITY_EQUIV = {
    '<' => '&lt;',
    '>' => '&gt;',
    '&' => '&amp'
  }
  
  def initialize(string)
    super(string)
    gsub!(/[\<\>\&]/) { |m| HTML_ENTITY_EQUIV[m] }
  end
end

class String
  def self.rand(length = 12)
    Random.new(length)
  end
  
  def html_safe
    HtmlSafe.new(self)
  end
end
