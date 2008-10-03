class CopyController < ApplicationController
  
  layout 'main', :except => 'show'
  
  def highlight
    @copy = Copy.new(:url => params[:url], :search_id => params[:s].to_i)
    if @copy.save
      HighlightManager.run(@copy.id)
      redirect_to :action => 'show', :id => @copy.id
    end
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    redirect_to '/'
  end
  
  def show
    @copy = Copy.find_by_id params[:id].to_i
  end
  
  def update
    if request.xhr?
      bj = Bj.table.job.find(session[:job_id].to_i)
      if bj.finished?
        # completed without errors
        if bj.exit_status == 0
          render :update do |page| 
            session[:job_id] = nil
            copy_id = session[:job_copy_id].to_i
            session[:job_copy_id] = nil
            page.redirect_to :action => 'show', :id => copy_id        
          end    
        else         
          session[:job_id] = nil
          session[:job_copy_id] = nil
          #handle errors
          render :update do |page|
            page.redirect_to :action => 'index'
          end
        end
      else
         render :text => 'still working on highlighting your content ...'
      end
    else
       redirect_to '/'
    end
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    render :update do |page|
      session[:job_id] = nil
      page.redirect_to( '/')
    end
  end
  
end
