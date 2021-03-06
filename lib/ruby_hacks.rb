module RubyHacks
end

class Array
  def to_h(*seeds, &block)
    case (seeds.length)
    when 0
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
  
  if (defined?(ActiveSupport))
    # Use ActiveSupport random number generator if available
    
    def shuffle
      sort_by { ActiveSupport::SecureRandom.random_number }
    end
    
    def rand
      self[ActiveSupport::SecureRandom.random_number(length)]
    end
  else
    def shuffle
      sort_by { rand }
    end
  end
end

class Hash
  def dig(*path)
    path.inject(self) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end

  def merge_with!(*hashes)
    hashes.flatten.each do |hash|
      merge!(hash) if (hash && !hash.empty?)
    end
  end
  
  def merge_with(*hashes)
    hashes.flatten.inject(self) do |chain, hash|
      (hash && !hash.empty?) ? chain.merge(hash) : chain
    end
  end
  
  def downcase_keys
    map_keys(&:downcase)
  end

  def downcase_keys!
    map_keys!(&:downcase)
  end
  
  def map_keys
    inject({ }) do |h, (k, v)|
      h[yield(k)] = v
      h
    end
  end

  def map_keys!
    replace(
      inject({ }) do |h, (k, v)|
        h[yield(k)] = v
        h
      end
    )
  end
end

class String::Random < String
  RANDOM_LETTERS = [ ('a'..'z'), ('A'..'Z'), ('0'..'9') ].collect { |c| c.collect }.flatten.freeze
  
  def initialize(length = 12)
    super((1..length).collect { RANDOM_LETTERS.rand }.to_s)
  end
end

class String::RandomPhonetic < String
  CONSONANTS = %w( b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr )
  VOWELS = %w( a e i o u y )

  def initialize(length = 12)
    super(
      (1 .. length).collect { |n|
        (n % 2 != 0) ? CONSONANTS[rand(CONSONANTS.size)] : VOWELS[rand(VOWELS.size)]
      }.to_s[0, length]
    )
  end
end

class String::HtmlSafe < String
  HTML_ENTITY_EQUIV = {
    '<' => '&lt;',
    '>' => '&gt;',
    '&' => '&amp;'
  }
  
  def initialize(string, escape = true)
    super(string)
    gsub!(/[\<\>\&]/) { |m| HTML_ENTITY_EQUIV[m] } if (escape)
  end
  
  def html_safe
    self
  end
end

class String
  def self.rand(length = 12)
    Random.new(length)
  end

  def self.rand_phonetic(length = 12)
    RandomPhonetic.new(length)
  end

  if (!String.instance_methods.include?(:html_safe) and !String.instance_methods.include?('html_safe'))
    def keep_raw_html!
      @raw_html = true
      self
    end
  
    def html_safe!
      replace(HtmlSafe.new(self))
      self
    end
  
    def html_safe
      @raw_html ? self : HtmlSafe.new(self)
    end
  end
end
