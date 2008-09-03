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
    def highlight_copied_text(orig_url, c_doc)
      # save site that copied original html to use to highlight later
      copy_site_html = c_doc.inner_html
      # create doc from original url to strip and get terms to find
      doc = Hpricot(get_html(orig_url) || '', :xhtml_strict => true)
      strip_junk_tags(doc)
      # search text is an array of text from original site broken down into 5 word chunks.
      # the order is kept from top down to make it easier when scaning each line to highlight found 
      # groups of words
      search_text = extract_search_text(doc)
      # gather grep terms to search for in the copied sites plain text to find copied words
      grep_list = create_grep_list(search_text)
      # now grep through the copied site document with regex to find the copied group words
      # collect original group words so a count can be made
      copied_text = find_copied_words(c_doc, grep_list, search_text)
      # collect regex list to locate words to highlight
      regex_list = create_grep_list(copied_text)
      # get html from copied site and scan through it highlighting found words
      html = tidy.clean(scan_and_highlight_found_words(copied_text, regex_list, copy_site_html))
      # count of how many words where found that where copied
      count = 0
      copied_text.each{|c| count += c.split.size}
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
  
    def scan_and_highlight_found_words(word_list, regex_list, html)
      new_html = ''
      sc = StringScanner.new( html )
      puts "HERE IS THE HTML OF COPIED SITE ************************************"
      pp html
      puts "*********************************"
      puts "**********************************"
      @make_new_tag  = true
      @close_tag   = true
      counter = 0
      # grab everything until the body of html doc and add to html
      # begin searching for words in the body
      new_html << sc.scan_until(/<body.*?>/)
      regex_list.each do |regex|
        puts "HERE IS THE REGEX FOR SEARCHING ON COPIED SITE ***************************"
        pp regex
        # scan for copied words
        if (text = sc.scan_until(regex))
          if (counter + 1) == regex_list.size
            # end of group words make sure close_tag is true
            @close_tag   = true
          else
            # check if the highlight tag should be closed by finding index of next group of words
            next_words_size = word_list[counter + 1].length
            next_regex      = regex_list[counter + 1]
            index           = sc.rest.index(next_regex)          
            @close_tag = ((index <= 25) ? false : true)
          end
          new_html << highlight_word(word_list[counter], text)        
        end  # end of check if text was found with scan
        counter += 1
      end
      # add remaining text in string scanner to new html
      new_html << sc.rest
    end
    
    def highlight_word(word, text)
      words       = word.split
      first_word  = words.shift
      group_size  = words.join.length
      if @make_new_tag
        # find index of first word
        index = text.rindex(first_word, -group_size)
        # insert start of highlight tag
        offset = ((index - 1) - text.length) # subtract 1 from index so that tag goes before first character
        text.insert(offset, "<strong style='background-color: #FAD089;'>")
      end
      # check if we should add the close tag to found words
      text << '</strong>' if @close_tag
      @make_new_tag = (@close_tag ? true : false)
      text
    end
    
    # remove script, font, meta .... all junk tags from document
    def strip_junk_tags(doc)
      Constants::SEARCH_TAG_SCRUB_CONFIG[:remove].each { |tag| (doc/tag).remove }
    end
    
    def tidy
      @@tidy ||= Tidy.new
    end
    
    # you can optimize this by doing a scan from an index location past the previous found group of words
    def find_copied_words(doc, grep_list, search_text)
      found_words = []
      # strip document first
      strip_junk_tags(doc)
      doc.to_plain_text
      text = doc.inner_text
      counter = 0
      grep_list.each do |regex|
        unless (sr = text.scan(regex)).blank?
          puts "HERE IS THE SCAN RESULTS FOR REGEX **************** #{regex}"
          pp sr
          # we found copied words add original words from search_text
          found_words << search_text[counter]
        end
        counter += 1
      end
      found_words
    end
    
    # make a hash with group words index in search_terms array as key and grep regex as value
    def create_grep_list(search_list)
      grep_list = []
      search_list.each do |term|
        #reg_list[counter] = /(?im:\b#{first}.*?#{middle}.*?#{last}.*?\b)/
        grep_list << /(?im:\b#{term.split.collect{|s| s.to_s + '.*?'}}\b)/
      end
      grep_list
    end
    
    def extract_text(doc)
      col = []
      col = extract(doc, col, 'short')
      col = extract(doc, col, 'long')
      col
    end
    
    def extract(doc, col, term_type)
      tag_list = case term_type
      when 'short'
        Constants::SEARCH_TAG_SCRUB_CONFIG[:search_tags][:short_terms]
      when 'long'
        Constants::SEARCH_TAG_SCRUB_CONFIG[:search_tags][:long_terms]
      end
      tag_list.each do |tag|
        while (tags = doc/tag).size > 0
          elem = tags.reverse.first
          elem.to_plain_text
          # remove all symbols and numbers and grab all remaining words over the length of 2
          text_list = elem.inner_text.gsub(/\b([^A-Za-z\s]+)\b/, ' ').scan(/[\w+]{2,}/)
          term_type == 'short' ? add_to_collection(text_list, col, 7) : add_to_collection(text_list, col)
          # remove element from document after text is extracted
          elem.remove
        end
      end
      col
    end
    
    # this is for getting the search text from the original url to grep against the copy url 
    # to find copied groups of words.  Get only groups of words that are > 5
    # Take any groups of words that are greater then 8 and break them down
    def extract_search_text(doc)
      col = []
      doc.to_plain_text
      doc.inner_text.scan(/([^\t\n\r]+\w+)/).each do |s|
        col << s.to_s.gsub(/([^a-zA-Z]+)/, ' ').scan(/[\w+]{2,}/).join(' ')
      end
      # now sift thru and only keep the groupings over 5 words long
      final_col = []
      col.collect do |words| 
        group_size = words.split.size
        if group_size >= 5 && group_size < 11
          final_col << words
        elsif group_size > 10
          word_array = words.split
          while word_array.size > 10
            final_col << word_array.slice!(0,7).join(' ')
          end
          final_col << word_array.join(' ')
        end
      end
      final_col
    end

    def add_to_collection(text_list, col, min = 7)
      text = text_list.join(' ')
      col << text unless text_list.size < min or col.include?(text)
    end
    
  end  
end
