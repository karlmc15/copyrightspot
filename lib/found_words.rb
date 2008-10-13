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
    @text.length
  end
  
  def word_size
    @text.split.size
  end
  
  def regex
    s = @text.split.size
    r = ''
    @text.split.inject(1) do |counter, word|
      r << (counter == s ? word.to_s : word.to_s + '.{0,200}')
      counter += 1
    end
    /(?im:\b#{r}\b)/
  end
  
  def first_word
    @text.split[0]
  end
  
  def add_text(text)
    @text = @text + ' ' + text
  end
  
end