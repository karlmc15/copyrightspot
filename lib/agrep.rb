require 'amatch'

class Agrep
  
  def self.has_match?(pattern, text)
    calc_distance(pattern, text) <= threshold
  end
  
  def self.normalize_distance(dis, pattern)
    # normalize results by dividing results by patten size
    dis.to_f / pattern.length
  end
  
  # this setting will need to be analyzed and optimized
  def self.threshold
    0.35
  end
  
  def self.calc_distance(pattern, text)
    amatch  = Amatch::Levenshtein.new(pattern.downcase)
    dis = amatch.search(text.downcase)
    normalize_distance(dis, pattern)
  end
  
end

module Enumerable
  
  # assumes that the array that this is being called on contains the patterns
  def agrep(text, &block)
    matches = select { |obj| Agrep.has_match?(obj.to_s, text) }

    block ? matches.map(&block) : matches
  end
  
end