module RubyHacks
  VERSION = '0.0.1'
end

# -- Array ------------------------------------------------------------------

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

# -- Hash -------------------------------------------------------------------

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

# -- String -----------------------------------------------------------------

class String::HtmlSafe < String
  HTML_EQUIVALENT = {
    '<' => '&lt;',
    '>' => '&gt',
    '&' => '&amp;'
  }
  
  def initialize(string)
    super(string.gsub(/[<>&]/) { |s| HTML_EQUIVALENT[s] })
  end
end

class String::Random < String
  CHARACTER_SET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split(//).freeze
  
  AVOID_WORDS = Regexp.new(%w[
    ass a55 as5 a5s
    bal
    bit btc b1t
    bul bll bls
    but btu
    chi ch1
    cun cnt
    dic dik d1c d1k
    fag f4g
    fuc fuk fck fcu fkn fkc
    kik kyk k1k
    jer jrk j3r
    jew j3w
    mot m0t mth mtr m7r
    neg n3g ngr
    nig n1g
    pof p0f
    poo po0 p00
    que qu3 qee q3e qe3
    shi sh1 shy
    stf sfu
    spi sp1
    tar t4r trd
    wtf wth
    xxx
  ].join('|'))
  
  def initialize(length)
    while (true)
      random_word = (1..length).inject('') { |b,x| b << CHARACTER_SET.rand }
      
      if (!AVOID_WORDS.match(random_word))
        return super(random_word)
      end
    end
  end
end

class String
  def self.rand(length = 16)
    Random.new(length)
  end
  
  def html_safe
    HtmlSafe.new(self)
  end
end
