class Highlight
  
  def self.run(text, search_words_list)
    pool = ThreadPool.new(10)
    @found_words = []
    @text = text
    search_words = search_words_list.inject([]){ |list, words| list << SearchWords.new(words) }
    search_words.each do |sw|
      pool.dispatch(sw) do |sw|
        # search until all words searched
        until(sw.all_words_searched?) do 
          regex = sw.base_regex
          scan_results = @text.scan(regex)
          index = 0
          next_index = 0
          # find list of actual indexes for this regex
          index_list = scan_results.inject([]) do |list, result|
            begin_index = @text[next_index, (@text.length)].index(regex)
            if begin_index
              # now look for index in smaller chunk
              index =+ (next_index + begin_index)
              next_index = index + sw.search_size            
              sub_text = @text[index, (sw.search_size)]
              # recheck index to make sure it's in chunk
              index_check = sub_text.index(regex)
              if index_check
                # we found an actual match save in list so we can process later
                # add prevoud index so we have actual location in doucment
                list << (index)
              end
            end
            list
          end # end of scan_results inject block
          # take index list and find out how many more words we can match
          unless index_list.blank?
            # we want to record these found words but first see how many more words we can match
            words_added_count = 0
            index_list.each do |found_index|
              # duplicate search_word so we don't advance the search word list until all in the index_list are searched independently
              d_sw = sw.dup
              counter = 0
              until(!get_text(found_index, d_sw, @text).index(rx = d_sw.next_regex) || d_sw.all_words_searched?) do 
                counter += 1
              end
              # we've advanced the search word counter now create a found word from it
              ft = d_sw.found_text
              @found_words << FoundWords.new(ft, found_index)
              words_added_count = counter if counter > words_added_count
            end
            # now we have the highest words moved forward with search_words object so move forward in main
            sw.advance_search_words(words_added_count)
          end
        end # end of all_words_searched loop
      end # end of thread pool dispatch
    end # end of search words loop
    # shutdown pool thread
    pool.shutdown
    pool = nil
    # sort and make found words list unique
    @found_words.sort!{|a, b| a.index <=> b.index}
    ensure_unique(@found_words)
  end
  
  private 
  
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