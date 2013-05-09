#
# This is a quick hack to get iDEAL payments working without modifying
# foodsoft's database model. Transactions are not stored while in process,
# only on success. Failed transactions leave no trace in the database,
# but they are logged in the server log.
#

class PaymentsController < ApplicationController

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
      xtranote = " (membership fee)"
    end

    request = IdealMollie.new_order((amount*100.0).to_i, "#{FoodsoftConfig[:name]} payment for #{@current_user.nick}#{xtranote}", bank_id)

    payments_id = request.payments_id
    logger.info "iDEAL start: #{amount} for #{@current_user.nick} with bank #{bank_id}#{xtranote}"

    # TODO: store the payments_id like:
    # For example:
    #   my_order = MyOrderObject.find(id)
    #   my_order.payments_id = payments_id
    #   my_order.save

    redirect_to request.url
  end

  def check
    transaction_id = params[:transaction_id]
    response = IdealMollie.check_order(transaction_id)
    logger.info "iDEAL check: #{response.inspect}"

    if response.paid
      @transaction = FinancialTransaction.new
      @transaction.amount = response.amount / 100.00
      # TODO verify response.currency = our currency
      @transaction.ordergroup = @current_user.ordergroup.id
      @transaction.note = self.ideal_note(transaction_id)
      @transaction.user = @current_user.id
      @transaction.add_transaction!
    else
      # TODO: store the result information for the canceled payment
      # For example:
      #   my_order = MyOrder.find_by_payments_id(payments_id)
      #   my_order.paid = false
      #   my_order.save
    end
    render :nothing => true
  end

  def result
    transaction_id = params[:transaction_id]
    @transaction = FinancialTransaction.where(:note => self.ideal_note(transaction_id)).first
    if @transaction
      logger.info "iDEAL result: transaction #{transaction_id} succeeded"
      redirect_to ordergroup_home_path, :notice => "#{@transaction.user.nick} has been credited with &euro;#{@transaction.amount}"
    else
      logger.info "iDEAL result: transaction #{transaction_id} failed"
      redirect_to url_for(:action => :index), :alert => 'payment failed' # TODO save from check's response.message
    end
  end

  protected
  def ideal_note(transaction_id)
    "iDEAL payment (#{transaction_id})"
  end
end
