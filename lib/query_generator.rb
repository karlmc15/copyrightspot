module QueryGenerator
  class << self
    
    def search_terms(search_hash)
      queries = chop_long_terms(search_hash)
      a = []
      while queries.size > 2
        n = 2
        query_list = queries.slice!(-n, n)
        a << form_query(query_list)
      end
      a << form_query(queries) if queries.size > 0
      a
    end
    
    private
    
    def form_query(list)
      size = list.size
      counter = 1
      list.inject('') do |query_string, query|
        query_string << "\"#{query}\"#{' OR ' unless counter == size}"
        counter += 1
        query_string
      end
    end
    
    def chop_long_terms(search_hash)
      @queries = []
      search_hash.each do |key, value|
        @queries << value.flatten.uniq.inject([]) do |col, term|
          # form term array of words
          ta = term.split
          term_size = ta.size
          # now check for huge text blocks and seperate them up
          if term_size >= 21
            (term_size / 15).times do 
              len = term_size > 21 ? 15 : term_size
              text = ta.slice!(0..len)
              add_to_collection(text, col, key)
            end  
            # collect remaing text after chopping up 
            add_to_collection(ta, col, key)
          else
            add_to_collection(ta, col, key)
          end
          col
        end
      end
      @queries.flatten.uniq
    end
    
    # don't add word groups of less then 7 so we cut down on some of the noise 
    # from search engine results
    def add_to_collection(text, col, key)
      min_text_size = ( %w(h1 h2 h3).include?(key) ? 6 : 10 )
      col << text.join(' ') unless text.size < min_text_size || col.include?(text.join(' '))
    end
    
  end 
end