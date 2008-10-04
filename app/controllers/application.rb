# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  
  helper :all # include all helpers, all the time
  helper_method :extract_host
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => '1a2f52e62f40e939f979ceb4f9d248c8'
  
  layout 'main'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def extract_host
    host = request.host
    port = request.port
    %w(80 443).include?(port.to_s) ? host : "http://#{host}:#{port}"
  end
end
