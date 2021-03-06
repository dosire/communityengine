class AdminController < BaseController
  before_filter :admin_required
  
  def index
    redirect_to :action => :users
  end
  
  def users
    cond = Caboose::EZ::Condition.new
    if params['login']    
      cond.login =~ "%#{params['login']}%"
    end
    if params['email']
      cond.email =~ "%#{params['email']}%"
    end        
    
    @users = User.recent.find(:all, :page => {:current => params[:page], :size => 100}, :conditions => cond.to_sql)      
  end
  
  def activate_user
    user = User.find(params[:id])
    user.activate
    flash[:notice] = "The user was activated".l
    redirect_to :action => :users
  end
  
end