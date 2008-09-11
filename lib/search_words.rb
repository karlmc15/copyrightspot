class SearchWords
  attr_accessor :text
  
  def initialize(text)
    @text   = text
    @word_array = @text.split
  end
  
  def word_size
    @text.split.size
  end
  
  def word_array_size
    @word_array.size
  end
  
  # this should always move the shift search_words by one and continue through words_array
  def base_regex
    # if word_array is greater then 7 chop it down by 5 else use the whole thing
    if @search_words
      # we already have search_words to shift by one word
      @search_words.shift 
      @search_words << @word_array.shift
    else
      # create new search_words
      slice_end = (@word_array.size > 7 ? 4 : @word_array.size - 1)
      @search_words = @word_array.slice!(0..slice_end)
    end
    create_regex(@search_words)
  end
  
  def next_regex
    @search_words << @word_array.shift
    create_regex(@search_words)
  end
  
  def search_text
    @search_words ? @search_words.join(' ') : ''
  end
  
  def found_text
    # check if all words where searched then return the whole thing else pop one from the back which was added but caused the loop to end
    @search_words.pop unless all_words_searched? 
    @search_words.join(' ')
  end
  
  def advance_search_words(num)
    num.times{@word_array.shift}
    reset
  end
  
  def reset
    @search_words = nil
  end
  
  def search_size
    @search_words.join(' ').length + 21 
  end
  
  def create_regex(word_list)
    /(?im:\b#{word_list.collect{|s| s.to_s + '.*?'}}\b)/
  end
  
  def all_words_searched?
    @word_array.size == 0
  end
  
end