module Workling
  class WorklingError < StandardError; end
  class WorklingNotFoundError < WorklingError; end

  mattr_accessor :load_path
  @@load_path = File.expand_path(File.join(File.dirname(__FILE__), '../../../../app/workers')) 
  
  # determine the runner to use if nothing is specifically set. 
  def self.default_runner
    if Object.const_defined? "Spawn" # the spawn plugin is installed. 
      Workling::Remote::Runners::SpawnRunner.new
    elsif Object.const_defined? "Bj" # the backgroundjob plugin is installed. 
      Workling::Remote::Runners::BackgroundjobRunner.new
    else
      Workling::Remote::Runners::NotRemoteRunner.new
    end
  end
end