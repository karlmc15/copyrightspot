require 'hpricot'

class HighlightManager

  def self.run(copy_id)
    @copy = Copy.find_by_id copy_id
    @search = Search.find_by_id @copy.search_id
    # save site that copied original html to use to highlight later
    copy_site_html = HtmlManager.tidy_html(@copy.copy_doc.inner_html)
    # prepare the text from the copy site to scan through
    c_doc = @copy.copy_doc
    # strip document first
    HtmlManager.strip_junk_tags(c_doc)
    HtmlManager.remove_junk_content(c_doc)
    c_doc.to_plain_text
    # do a word scan so we have just pure text
    text = c_doc.inner_text.downcase.gsub(/\b([^A-Za-z\s]+)\b/, ' ').scan(/[\w+]{2,}/).join(' ')
    # now grep through the copied site document with regex to find the copied group words
    # collect original group words so a count can be made
    found_words = Highlight.run(text, @search.get_search_text)
    # count of how many words where found that where copied
    count = found_words.inject(0){|count, fw| count += fw.size}
    # set copy results 
    @copy.update_attribute(:found_count, count)
    # get html from copied site and scan through it highlighting found words
    # added html tidy cleanup so extra text is not highlighted but this remove some of the highlighting because it is bad html syntax
    # need to come up with a better way to highlight
    html = HtmlManager.tidy_html(scan_and_highlight_found_words(found_words, @copy.set_nav_in_html(copy_site_html)))
    # set navigation into html and save to file system
    @copy.save_html(html)      
  end
  
  private
  
  def self.scan_and_highlight_found_words(found_words, html)
    @new_html = ''
    sc = StringScanner.new( html )
    # grab everything until the body of html doc and add to html
    # begin searching for words in the body
    body = sc.scan_until(/<body.*?>/)
    @new_html << (body.nil? ? '' : body)
    first_match_found = false
    found_words.each do |found_word|
      # scan for copied words
      @text = sc.scan_until(found_word.regex)
      unless @text.nil?
        # find index of first word
        index = @text.rindex(/(?im:\b#{found_word.first_word}\b)/, -found_word.size)	        
        # insert start of highlight tag
        offset = ((index - 1) - @text.length) # subtract 1 from index so that tag goes before first character
        anchor_tag = ''
        unless first_match_found
          anchor_tag << "<a name='first_word'></a>"
          first_match_found = true
        end
        @text.insert(offset, "#{anchor_tag}<b style='background-color:#f7941e;'>")
        # add the close tag to found words
        @text << '</b>'
        @new_html << @text    
      end  # end of check if text was found with scan
    end
    @new_html << sc.rest
  end
  
end