module Boss
  class Response
    
    def initialize(response, method)
      @response = response['ysearchresponse']
      @method = method
    end
    
    def next_page
      @response['nextpage']
    end
    
    def code
      @response['responsecode']
    end
    
    def deep_hits
      @response['deephits']
    end
    
    def total_hits
      @response['totalhits']
    end
    
    def result_set
      @resultset ||= @response["resultset_#{@method}"].inject([]) do |col, result|
        col << Boss::Result.new(result)
      end
    end
    
  end
end