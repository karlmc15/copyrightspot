class Job < ActiveRecord::Base
  COMPLETE    = 'COMPLETE'
  ERROR       = 'ERROR'
  WORKING     = 'WORKING'
  STARTING    = 'STARTING'
end
