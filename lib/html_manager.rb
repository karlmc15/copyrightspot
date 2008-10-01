require 'hpricot'
require 'hpricot_scrub'
require 'mechanize'
require 'asciify'

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
    
    def set_head_navigation(doc, url, count, host)
      nav = "<div style='width:100%;height:100px;text-align:center;background-color:white;padding-top:15px;'><img src='#{host}/images/cspot_small.gif'/><h4>This site has copied #{count} words from your site.</h4><p style='line-height:30px;margin-left:43%;margin-right:40%;'><a href='#{host + url}'>Return to your content discoveries</a></p></div>"
      html = doc.at('html')
      html.inner_html = (nav + html.inner_html)
    end
    
    def get_host(url)
      uri = URI.parse(url)
      uri.scheme + '://' + uri.host
    end
    
    # remove script, font, meta .... all junk tags from document
    def strip_junk_tags(doc)
      Constants::SEARCH_TAG_SCRUB_CONFIG[:remove].each { |tag| (doc/tag).remove }
    end
    
    # go through and try and remove block tags which contain comments, banners or ads
    def remove_junk_content(doc)
      junk = %w(comment banner)
      Constants::SEARCH_TAG_SCRUB_CONFIG[:banner_tags].each do |tag| 
        list = (doc/tag)       
        list.reverse.each do |e| 
          found_junk = false
          # check if classes conains 
          junk.each do |junk_tag|
            # look in class
            found = e.classes.collect{|c| c =~ /#{junk_tag}/}
            found.compact!
            unless found.blank?
              found_junk = true
              break 
            end
            # look in id
            if e.get_attribute('id').to_s =~ /#{junk_tag}/
              found_junk = true
              break 
            end
          end
          e.remove if found_junk
        end
      end
    end
    
    def tidy
      @@tidy ||= Tidy.new
    end
    
    # returns an array of words that are grouped together in the html doc
    # minimum group of words is 5 and no maximum
    # parse into smaller chunks of words in query generator before doing a search for them
    # or search on copied site
    def extract_text(doc)
      # setup convertion map for non-ascii characters
      map = Asciify::Mapping.new(:default)

      Constants::SEARCH_TAG_SCRUB_CONFIG[:search_tags].inject({}) do |col, tag|
        # setup hash with tag key to a new array to populate with search text results
        col[tag] = [] 
        while (tags = doc/tag).size > 0
          elem = tags.reverse.first
          elem.to_plain_text
          # remove all symbols and numbers and grab all remaining words over the length of 2
          text_list = elem.inner_text.asciify(map).downcase.gsub(/\b([^A-Za-z\s]+)\b/, ' ').scan(/[\w+]{2,}/)
          add_to_collection(text_list, col, tag)
          # remove element from document after text is extracted
          elem.remove
        end
        col
      end.reject{ |key, value| value.blank? }
    end
    
    def add_to_collection(text_list, col, tag)
      text = text_list.join(' ')
      col[tag] << text unless text_list.size < 5 or col[tag].include?(text)
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
