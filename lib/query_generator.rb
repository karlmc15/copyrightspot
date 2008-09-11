module QueryGenerator
  class << self
    
    def search_terms(term_list)
      prepare_search(term_list)
    end
    
    private

    def prepare_search(terms)
      queries = chop_long_terms(terms)
      puts "HERE ARE THE QUERIES ************"
      pp queries
      a = []
      while queries.size > 2
        n = 2
        query_list = queries.slice!(-n, n)
        a << form_query(query_list)
      end
      a << form_query(queries) if queries.size > 0
      a
    end
    
    def form_query(list)
      size = list.size
      counter = 1
      list.inject('') do |query_string, query|
        query_string << "\"#{query}\"#{' OR ' unless counter == size}"
        counter += 1
        query_string
      end
    end
    
    def chop_long_terms(terms)
      terms.inject([]) do |col, term|
        # form term array of words
        ta = term.split
        term_size = ta.size
        # now check for huge text blocks and seperate them up
        if term_size >= 18
          (term_size / 12).times do 
            len = term_size > 18 ? 12 : term_size
            text = ta.slice!(0..len)
            add_to_collection(text, col)
          end  
          # collect remaing text after chopping up 
          add_to_collection(ta, col)
        else
          add_to_collection(ta, col)
        end
        col
      end
    end
    
    # don't add word groups of less then 7 so we cut down on some of the noise 
    # from search engine results
    def add_to_collection(text, col)
      col << text.join(' ') unless text.size < 7 || col.include?(text.join(' '))
    end
    
  end 
end