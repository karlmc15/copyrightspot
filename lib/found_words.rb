class FoundWords
  attr_reader :text, :index
  
  def initialize(text, index)
    @text   = text
    @index  = index
  end
  
  def word_coverage
    @index + @text.length
  end
  
  def size
    @text.split.size
  end
  
  def regex
    /(?im:\b#{@text.split.collect{|s| s.to_s + '.*?'}}\b)/
  end
  
  def first_word
    @text.split[0]
  end
  
end