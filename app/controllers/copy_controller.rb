class CopyController < ApplicationController
  
  def highlight
    @copy = Copy.new(:url => params[:url], :search_id => params[:s].to_i)
    if @copy.save
      # discover manager returns job id
      HighlightManager.run(@copy.id)
      redirect_to :action => 'show', :id => @copy.id
    end
  end
  
  def show
    puts "WHAT ARE MY PARAMS ***************************************"
    pp params
    @copy = Copy.find_by_id params[:id].to_i
  end
  
  def update
    if request.xhr?
      puts "I'M TRYING TO GET THIS JOB ****************** #{session[:job_id]}"
      hj = HighlightJob.find_by_id(session[:job_id].to_i)
      if hj.status == HighlightJob::COMPLETE
        session[:job_id] = nil
        render :update do |page|
          page.redirect_to :action => 'show', :id => hj.copy_id
        end
      elsif hj.status == HighlightJob::ERROR
        session[:job_id] = nil
        render :update do |page|
          page.redirect_to :controller => 'search', :action => 'index'
        end
      else
        render :text => 'still working on highlighting copies of your content ...'
      end
    end
  end
  
end
