# encoding: utf-8
class LoginController < ApplicationController
  skip_before_filter :authenticate        # no authentication since this is the login page
  before_filter :validate_token, :only => [:new_password, :update_password]

  # Display the form to enter an email address requesting a token to set a new password.
  def forgot_password
    @user = User.new
  end
  
  # Sends an email to a user with the token that allows setting a new password through action "password".
  def reset_password
    if request.get? || params[:user].nil? # Catch for get request and give better error message.
      redirect_to forgot_password_url, alert: 'Ein Problem ist aufgetreten. Bitte erneut versuchen' and return
    end

    if (user = User.find_by_email(params[:user][:email]))
      user.reset_password_token = user.new_random_password(16)
      user.reset_password_expires = Time.now.advance(:days => 2)
      if user.save
        Mailer.reset_password(user).deliver
        logger.debug("Sent password reset email to #{user.email}.")
      end
    end
    redirect_to login_url, :notice => I18n.t('login.controller.reset_password.notice')
  end
  
  # Set a new password with a token from the password reminder email.
  # Called with params :id => User.id and :token => User.reset_password_token to specify a new password.
  def new_password
  end
  
  # Sets a new password.
  # Called with params :id => User.id and :token => User.reset_password_token to specify a new password.
  def update_password
    @user.attributes = params[:user]
    if @user.valid?
      @user.reset_password_token = nil
      @user.reset_password_expires = nil
      @user.save
      redirect_to login_url, :notice => I18n.t('login.controller.update_password.notice')
    else
      render :new_password
    end
  end

  # For invited users.
  def accept_invitation
    @invite = Invite.find_by_token(params[:token])
    if @invite.nil? || @invite.expires_at < Time.now
      redirect_to login_url, alert: I18n.t('login.controller.error_invite_invalid')
    elsif request.post?
      User.transaction do
        @user = User.new(params[:user].reject {|k,v| k=='ordergroup'})
        @user.email = @invite.email
        @group = @invite.group
        # create new group if not part of invite
        if @group.nil?
          @group = Ordergroup.new({
            :name => @user.nick,
            :contact_person => @user.name,
            :contact_phone => @user.phone
          }.merge(params[:user][:ordergroup]))
        end
        if @user.save
          Membership.new(:user => @user, :group => @group).save!
          @invite.destroy
          redirect_to login_url, notice: I18n.t('login.controller.accept_invitation.notice')
        end
      end
    else
      @user = User.new(:email => @invite.email)
    end
  end

  protected

  def validate_token
    @user = User.find_by_id_and_reset_password_token(params[:id], params[:token])
    if (@user.nil? || @user.reset_password_expires < Time.now)
      redirect_to forgot_password_url, alert: I18n.t('login.controller.error_token_invalid')
    end
  end
end
