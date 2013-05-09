#
# This is a quick hack to get iDEAL payments working without modifying
# foodsoft's database model. Transactions are not stored while in process,
# only on success. Failed transactions leave no trace in the database,
# but they are logged in the server log.
#
# Mollie's check url that is used contains the userid as the last path
# component, so that a financial transaction can be created on success
# for that user and ordergroup.
#
# Perhaps a cleaner approach would be to create a financial transaction
# without amount zero when the payment process starts, and keep track
# of the state using that. Then the transaction id would be enough to
# process it, and also an error message could be given.
#

class PaymentsController < ApplicationController

  skip_before_filter :authenticate, :only => [:check]

  def index
    @banks = IdealMollie.banks
    @amount = params[:amount]
  end

  def membership
    @banks = IdealMollie.banks
    @initial = true
    @amount = FoodsoftConfig[:membership_fee]
    render :index
  end

  def start
    # redirect to banks if there is no bank_id given
    redirect_to payments_path if params[:bank_id].nil?
    bank_id = params[:bank_id]
    amount = params[:amount].to_f
    xtranote = ''
    if params[:initial]
      amount = FoodsoftConfig[:membership_fee]
      xtranote = ' ' + I18n.t('payments.start.membership_fee')
    end

    IdealMollie::Config.return_url = url_for(:action => :result, :only_path => false)
    IdealMollie::Config.report_url = url_for(:action => :check, :only_path => false, :id => @current_user.id)
    request = IdealMollie.new_order((amount*100.0).to_i, I18n.t('payments.start.payment_note', :foodcoop => FoodsoftConfig[:name], :username => @current_user.nick) + xtranote, bank_id)

    transaction_id = request.transaction_id
    logger.info "iDEAL start: #{amount} for #{@current_user.nick} with bank #{bank_id}#{xtranote}"

    redirect_to request.url
  end

  def check
    transaction_id = params[:transaction_id]
    response = IdealMollie.check_order(transaction_id)
    logger.info "iDEAL check: #{response.inspect}"

    if response.paid
      user = User.find(params[:id])
      amount = (response.amount/100.0).to_s
      amount.gsub!('\.',I18n.t('separator')) # workaround localize_input problem
      @transaction = FinancialTransaction.new
      @transaction.user_id = user.id
      @transaction.ordergroup_id = user.ordergroup.id
      @transaction.amount = amount
      @transaction.note = self.ideal_note(transaction_id)
      @transaction.add_transaction!
    end
    render :nothing => true
  end

  def result
    transaction_id = params[:transaction_id]
    @transaction = FinancialTransaction.where(:note => self.ideal_note(transaction_id)).first
    if @transaction
      logger.info "iDEAL result: transaction #{transaction_id} succeeded"
      redirect_to url_for(:controller => :home, :action => :ordergroup), :notice => I18n.t('payments.result.notice')
    else
      logger.info "iDEAL result: transaction #{transaction_id} failed"
      redirect_to url_for(:action => :index), :alert => I18n.t('payments.result.failed') # TODO recall check's response.message
    end
  end

  protected
  def ideal_note(transaction_id)
    # XXX do check that translation contains transaction id, or all second and later transactions will always succeed
    I18n.t('payments.ideal_note.note', :transaction_id => transaction_id)
  end
end
