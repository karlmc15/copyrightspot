class Notify < ActiveRecord::Base

  def self.verify_and_save(email, page)
    self.new(:email => email, :page => page).save if email_valid?(email)
  end
  
  def self.email_valid?(email)
    email =~ /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$/i
  end

end
