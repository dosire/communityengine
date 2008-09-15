# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #For the session key see environment.rb!
  exempt_from_layout :builder
  before_filter :set_language_to_english, :set_person
   
  def set_language_to_english
    @language = Language.find_by_iso_code("en")
  end
  
  def set_language
    begin
      if request.domain == "localhost" or request.domain == "production"
        subdomain = "en"
      else
        subdomain = request.subdomain[0]
      end
      case subdomain
      when "www"
        @language = Language.find_by_iso_code("en")
      when nil
        @language = Language.find_by_iso_code("en")
        flash[:notice] = "Please use www.appappeal.com instead of appappeal.com"
        redirect_to(root_url)
      else
        @language = Language.find_by_iso_code(subdomain)
      end
    rescue
      @language = Language.find_by_iso_code("en")
      flash[:notice] = "Invalid subdomain, this language is not supported yet."
      redirect_to(root_url)
    end
  end
  
  def default_url_options(options = nil)
    { :trailing_slash => true }
  end
  
  def set_flash(options)
    if request.xhr?
      flash.now[:notice] = options
    else
      flash[:notice] = options
    end
  end
  
  def set_person
    if session[:person_id]
      @person = Person.find_by_id(session[:person_id]) 
    else
      @person = nil
    end
  end

  def login_person(email, password)
    session[:person_id] = nil
    person = Person.validate_credentials(email, password)
    if person
      session[:person_id] = person.id
      set_person
      flash[:notice]  = "Login succesfull"
      uri = session[:original_uri]
      session[:original_uri] = nil
      redirect_to(uri) if uri
    else
      flash[:notice]  = "Invalid email address or password"
      redirect_to_login_page
    end
  end
  
  def logout_person
    session[:person_id] = nil
    set_person
    flash[:notice] = "Logout succesfull"
    redirect_to(:controller => "profile", :action => "login")
  end
  
  def account
    redirect_to_login_page(Person.find_roles(:account)) unless (@person.account? rescue nil)
  end

  def administrative
    redirect_to_login_page(Person.find_roles(:administrative)) unless (@person.administrative? rescue nil)
   end
  
  def static_content
    redirect_to_login_page(Person.find_roles(:static_content)) unless (@person.static_content? rescue nil)
  end
  
  def nobody
    redirect_to_login_page(Person.find_roles(:nobody)) unless (@person.nobody? rescue nil)
  end
  
  def set_active_scaffolding_head
    @javascripts = [
      "active_scaffold/default/active_scaffold.js",
      "active_scaffold/default/dhtml_history.js",
      "active_scaffold/default/form_enhancements.js",
      "active_scaffold/default/rico_corner.js"
    ]
    #IE hack not good because we selected compatible mode? @stylesheets = ["active_scaffold/default/stylesheet-ie"] if request.user_agent =~ /msie/i  
    @stylesheets = ["active_scaffold/default/stylesheet"]
  end
  
  protected
  
  def redirect_to_login_page(required_roles = nil)
    if required_roles
      if session[:person_id]
        flash[:notice] = "The page you requested can only be accessed by " + required_roles.to_sentence(:skip_last_comma => true) + " roles."
      else
        flash[:notice] = "Please log in for access."
      end
    end
    session[:original_uri] = request.get? ? request.request_uri : request.env["HTTP_REFERER"]
    redirect_to(:controller => :profile, :action => :login)
  end
end
