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
      query = ''
      size = list.size
      counter = 1
      list.each do |q|
        query << "\"#{q}\"#{' OR ' unless counter == size}"
        counter += 1
      end
      return query
    end
    
    def chop_long_terms(terms)
      col = []
      terms.each do |term|
        # form term array of words
        ta = term.scan(/\w+/)
        term_size = ta.size
        # now check for huge text blocks and seperate them up
        if term_size >= 21
          (term_size / 15).times do 
            len = term_size > 21 ? 15 : term_size
            text = ta.slice!(0..len)
            add_to_collection(text, col)
          end  
          # collect remaing text after chopping up 
          add_to_collection(ta, col)
        else
          col << term
        end
      end
      col
    end
    
    def add_to_collection(text, col)
      col << text.join(' ') unless text.size < 5 || col.include?(text.join(' '))
    end
    
  end 
end