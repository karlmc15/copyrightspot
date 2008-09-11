require 'hpricot'
require 'hpricot_scrub'
require 'mechanize'

module HtmlManager
  class << self
    
    def collect_search_text(url)
      doc = Hpricot(get_html(url) || '', :xhtml_strict => true)
      raise 'document is empty' if doc.nil?
      strip_junk_tags(doc)
      # final collection of search strings with blanks removed
      extract_text(doc)
    end

    def get_html(url)
      agent = WWW::Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'
      # fix bad html and clean up tags
      tidy.clean(agent.get(url).body)
    end
    
    # two hpricot documents are passed in so that one can be used to scrub and destroy while locating the text
    # the second document is then updated with found text highlited 
    # the search_list is the original search list used to locate the url with copied text
    def highlight_copied_text(search_text, c_doc)
      # save site that copied original html to use to highlight later
      copy_site_html = c_doc.inner_html
      # form array of words broken down into 5 word chunks
      search_words_list = search_text.inject([]){|col, text| col << SearchWords.new(text); col }
      # now grep through the copied site document with regex to find the copied group words
      # collect original group words so a count can be made
      found_words_list = find_copied_words(c_doc, search_words_list)
      # get html from copied site and scan through it highlighting found words
      html = tidy.clean(scan_and_highlight_found_words(found_words_list, copy_site_html))
      # count of how many words where found that where copied
      count = found_words_list.inject(0){|count, fw| count += fw.size}
      return html, count
    end
    
    def set_html_base_url(doc, url)
      h = doc.at('head')
      base = "<base href=\"#{get_host(url)}\" />"
      if h.nil?
        # add our own head 
        html = doc.at('html')
        head = "<head>#{base}</head>"
        html ? html.inner_html = (head + html.inner_html) : doc.inner_html = (head + doc.inner_html)
      else
        h.inner_html = (base + h.inner_html)
      end
    end
    
    def set_head_navigation(doc, url, count)
      nav = "<div style='width:100%;height:100px;text-align:center;background-color:white;padding-top:15px;'><h2>Put a Badge on Your Website</h2><h4>This site has copied #{count} words from your site.</h4><p style='line-height:30px;margin-left:43%;margin-right:40%;'><a href='#{url}'>Return to Discovered Plagiarism</a></p></div>"
      html = doc.at('html')
      html.inner_html = (nav + html.inner_html)
    end
    
    def get_host(url)
      uri = URI.parse(url)
      uri.scheme + '://' + uri.host
    end

  #private
  
    def scan_and_highlight_found_words(found_words, html)
      new_html = ''
      sc = StringScanner.new( html )
      # grab everything until the body of html doc and add to html
      # begin searching for words in the body
      new_html << sc.scan_until(/<body.*?>/)
      found_words.each do |found_word|
        # scan for copied words
        if (text = sc.scan_until(found_word.regex))
          # find index of first word
          index = text.rindex(found_word.first_word, -found_word.size)
          # insert start of highlight tag
          offset = ((index - 1) - text.length) # subtract 1 from index so that tag goes before first character
          text.insert(offset, "<strong style='background-color: #FAD089;'>")
          # add the close tag to found words
          text << '</strong>'
          new_html << text       
        end  # end of check if text was found with scan
      end
      # add remaining text in string scanner to new html
      new_html << sc.rest
    end
    
    # remove script, font, meta .... all junk tags from document
    def strip_junk_tags(doc)
      Constants::SEARCH_TAG_SCRUB_CONFIG[:remove].each { |tag| (doc/tag).remove }
    end
    
    def tidy
      @@tidy ||= Tidy.new
    end
    
    # you can optimize this by doing a scan from an index location past the previous found group of words
    def find_copied_words(doc, search_words)
      # strip document first
      strip_junk_tags(doc)
      doc.to_plain_text
      # do a word scan so we have just pure text
      text = doc.inner_text.gsub(/\b([^A-Za-z\s]+)\b/, ' ').scan(/[\w+]{2,}/).join(' ')
      found_words_list = search_words.inject([]) do |found_words, sw|
        # search until all words searched
        until(sw.all_words_searched?) do 
          regex = sw.base_regex
          scan_results = text.scan(regex)
          index = 0
          next_index = 0
          # find list of actual indexes for this regex
          index_list = scan_results.inject([]) do |list, result|
            begin_index = text[next_index, (text.length)].index(regex)
            if begin_index
              # now look for index in smaller chunk
              index =+ (next_index + begin_index)
              next_index = index + sw.search_size            
              sub_text = text[index, (sw.search_size)]
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
              s_text = 
              until(!get_text(found_index, d_sw, text).index(rx = d_sw.next_regex) || d_sw.all_words_searched?) do 
                counter += 1
              end
              # we've advanced the search word counter now create a found word from it
              ft = d_sw.found_text
              found_words << FoundWords.new(ft, found_index)
              words_added_count = counter if counter > words_added_count
            end
            # now we have the highest words moved forward with search_words object so move forward in main
            sw.advance_search_words(words_added_count)
          end
        end # end of all_words_searched loop
        found_words
      end.sort{|a, b| a.index <=> b.index}
      ensure_unique(found_words_list)
    end
    
    def ensure_unique(found_words_list)
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
    
    def get_text(found_index, d_sw, text)
      text[found_index, d_sw.search_size]
    end
    
    # make a hash with group words index in search_terms array as key and grep regex as value
    def create_grep_list(search_list)
      search_list.inject([]) do |grep_list, term|
        regex = /(?im:\b#{term.split.collect{|s| s.to_s + '.*?'}}\b)/
        grep_list << regex
      end
    end
    
    # returns an array of words that are grouped together in the html doc
    # minimum group of words is 5 and no maximum
    # parse into smaller chunks of words in query generator before doing a search for them
    # or search on copied site
    def extract_text(doc)
      Constants::SEARCH_TAG_SCRUB_CONFIG[:search_tags].inject([]) do |col, tag|
        while (tags = doc/tag).size > 0
          elem = tags.reverse.first
          elem.to_plain_text
          # remove all symbols and numbers and grab all remaining words over the length of 2
          text_list = elem.inner_text.gsub(/\b([^A-Za-z\s]+)\b/, ' ').scan(/[\w+]{2,}/)
          add_to_collection(text_list, col)
          # remove element from document after text is extracted
          elem.remove
        end
        col
      end
    end
    
    def add_to_collection(text_list, col, min = 5)
      text = text_list.join(' ')
      col << text unless text_list.size < min or col.include?(text)
    end
    
    # Get only groups of words that are > 5
    # Take any groups of words that are greater then 8 and break them down
    def chop_search_text(search_list)
      search_list.inject([]) do |col, words| 
        group_size = words.split.size
        if group_size >= 5 && group_size < 8
          col << words
        else
          word_array = words.split
          while word_array.size > 7
            col << word_array.slice!(0,5).join(' ')
          end
          col << word_array.join(' ')
        end
        col
      end.uniq # make sure the returned search list has no duplicates
    end

    
  end  
end
