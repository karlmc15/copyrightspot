require 'asciify'
require 'hpricot'

class HighlightManager
  
  def self.run(copy_id)
    logger.info "#{self} - STARTED WORKER AT ********** #{Time.now}"
    # setup convertion map for non-ascii characters
    map = Asciify::Mapping.new(:default)
    begin
      @copy = Copy.find_by_id copy_id
      @search = Search.find_by_id @copy.search_id
      # save site that copied original html to use to highlight later
      copy_site_html = @copy.copy_doc.inner_html
      # prepare the text from the copy site to scan through
      c_doc = @copy.copy_doc
      # strip document first
      HtmlManager.strip_junk_tags(c_doc)
      HtmlManager.remove_junk_content(c_doc)
      c_doc.to_plain_text
      # do a word scan so we have just pure text
      text = c_doc.inner_text.asciify(map).downcase.gsub(/\b([^A-Za-z\s]+)\b/, ' ').scan(/[\w+]{2,}/).join(' ')
      # now grep through the copied site document with regex to find the copied group words
      # collect original group words so a count can be made
      found_words = Highlight.run(text, @search.get_search_text)
      # get html from copied site and scan through it highlighting found words
      html = HtmlManager.tidy.clean(scan_and_highlight_found_words(found_words, copy_site_html))
      # count of how many words where found that where copied
      count = found_words.inject(0){|count, fw| count += fw.size}
      # set copy results 
      @copy.update_attributes(:found_count => count, :html => html)
    rescue Exception => e
      logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    end    
    logger.info "#{self} - ENDED WORKER AT ********** #{Time.now}"
  end
  
  private
  
  def self.scan_and_highlight_found_words(found_words, html)
    begin
      new_html = ''
	    sc = StringScanner.new( html )
	    # grab everything until the body of html doc and add to html
	    # begin searching for words in the body
	    new_html << sc.scan_until(/<body.*?>/)
	    found_words.each do |found_word|
	      # scan for copied words
	      if (text = sc.scan_until(found_word.regex))
	        # find index of first word
	        index = text.rindex(/(?im:\b#{found_word.first_word}\b)/, -found_word.size)	        
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
    rescue Exception => e
      logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    end

  end
  
end