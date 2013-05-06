class InvitesController < ApplicationController

  # only admins can create invitations for any group
  before_filter :authenticate_membership_or_admin, :only => [:new]
  #TODO: authorize also for create action.
  # if enabled, allow anyone to request an invitation (with no ordergroup)
  if FoodsoftConfig.config[:invite_public]
    skip_before_filter :authenticate, :only => [:create_public]
  end
  
  def new
    @invite = Invite.new(:user => @current_user, :group => @group)
  end
  
  def create
    params[:invite][:user_id] = @current_user.nil? ? nil : @current_user.id
    @invite = Invite.new(params[:invite])
    if @invite.save
      Mailer.invite(@invite).deliver

      respond_to do |format|
        format.html do
          redirect_to back_or_default_path, notice: I18n.t('invites.success')
        end
        format.js { render layout: false }
      end

    else
      render action: :new
    end
  end

  def create_public
    # if not authenticated, bring up a thank you screen afterwards
    if @current_user.nil?
      session[:redirect_to] = url_for :controller => 'login', :action => 'thank_invitation'
    end
    params[:invite] = {:email => params[:invite][:email]}
    create
  end
end
