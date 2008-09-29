require 'workling/remote/runners/base'

module Workling
  module Remote
    module Runners
      class BackgroundjobRunner < Workling::Remote::Runners::Base
        cattr_accessor :routing
        
        def initialize
          BackgroundjobRunner.routing = 
            Workling::Starling::Routing::ClassAndMethodRouting.new
        end
        
        def run(clazz, method, options = {})
          stdin = @@routing.queue_for(clazz, method) + 
                  " " + 
                  options.to_xml(:indent => 0, :skip_instruct => true)
                  
          Bj.submit "./script/runner ./script/bj_invoker.rb", 
            :stdin => stdin
          
          return nil # that means nothing!
        end
      end
    end
  end
end