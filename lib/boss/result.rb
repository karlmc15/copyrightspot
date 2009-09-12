module Boss
  class Result
    
    def initialize(response)
      response.each do |key, value| 
        instance_variable_set("@#{key}", value) 
        instance_eval("def #{key}; @#{key}; end")
      end
    end
    
  end
end