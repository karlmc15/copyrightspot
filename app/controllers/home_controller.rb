class HomeController < ApplicationController
  
  def notify
    Notify.verify_and_save(params[:notify_email], params[:page])
    render :update do |page|
      page.replace_html 'opt_in_fields', "<p>You got it. We’ll be in touch.</p>"
    end
  end
  
end
