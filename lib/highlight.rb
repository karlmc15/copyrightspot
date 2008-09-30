require 'agrep'

class Highlight
  
  def self.run(text, search_words_list)
    pool = ThreadPool.new(20)
    @found_words = []
    @text = text
    search_words = search_words_list.inject([]){ |list, words| list << SearchWords.new(words) }
    # get a list of search words which pass our threshold
    search_words.each do |sw|
      pool.dispatch(sw) do |sw|
        # loop thru search word text and find matches using levensthein algorithm
        a_dis = Agrep.calc_distance(sw.to_s, @text)
        if a_dis == 0
          @found_words << find_words(sw, @text)
        elsif sw.word_size >= 10 
          # break text apart until 0's are found
          fw_list = sw.text_list.inject([]) do |fw_list, st|
            b_dis = Agrep.calc_distance(st, @text)
            if b_dis == 0
              fw_list << st
            elsif b_dis <= Agrep.threshold 
              # shuffle through the remaing words one word at a time to see if we can grab anything left
              # get text as word array
              aw_list = st.split
              base = aw_list.slice!(0,3).join(' ')
              ft = []
              counter = 0
              until aw_list.empty?
                base += " #{aw_list.shift}" unless counter == 0
                if Agrep.calc_distance(base, @text) == 0
                  # add current base to found text
                  ft << base
                else
                  # take a word off front of base
                  ba = base.split
                  ba.shift
                  base = ba.join(' ')
                end
                counter += 1
              end
              # find largest found text and add that too our found words
              unless ft.blank?
                ft.sort!{|a,b|a.length<=>b.length}
                fw_list << ft.pop
              end
            end
            fw_list
          end # end of search word text broken into smaller chunk loop
          unless fw_list.blank?
            @found_words << find_words(SearchWords.new(fw_list.join(' ')), @text)
          end
        end # end of add found words conditional statements
      end # end of thread pool loop
    end # end of agrep loop for search words
    # shutdown pool thread
    pool.shutdown
    pool = nil
    # sort and make found words list unique
    @found_words.flatten!
    @found_words.compact!
    @found_words.sort!{|a, b| a.index <=> b.index} unless @found_words.blank?
    ensure_unique(@found_words)    
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    raise "#{self} -- ERROR WHEN HIGHLIGHTING FOUND TEXT :: #{e.inspect}"
  end
  
  private
  
  # TODO add the ability to search the found words with more finner grained like first attempt  
  def self.find_words(search_word, text)
    # scan to see how many results there are
    index = 0
    next_index = 0
    regex = search_word.match_regex
    index_list = text.scan(regex).inject([]) do |list, result|
      begin_index = @text[next_index, (@text.length)].index(regex)
      if begin_index
        # now look for index in smaller chunk
        index =+ (next_index + begin_index)
        next_index = index + search_word.search_size            
        sub_text = @text[index, (search_word.search_size)]
        # recheck index to make sure it's in chunk
        index_check = sub_text.index(regex)
        if index_check
          # we found an actual match save in list so we can process later
          # add prevoud index so we have actual location in doucment
          list << (index)
        end
      end
      list
    end.collect{|index| FoundWords.new(search_word.to_s, index)}
  end 
 
  def self.ensure_unique(found_words_list)
    counter = 0
    found_words_list.inject([]) do |list, fw|
      if counter == 0
        list << fw
      else
        # check if previous entry already encompasses this search result
        # don't add entry if it has been covered
        unless found_words_list[counter - 1].word_coverage > fw.word_coverage
          list << fw
        end
      end
      counter += 1
      list
    end
  end
  
  def self.get_text(found_index, d_sw, text)
    text[found_index, d_sw.search_size]
  end
  
end