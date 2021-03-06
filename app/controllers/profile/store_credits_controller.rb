class Profile::StoreCreditsController < ApplicationController

  def show
    @store_credit = customer.store_credit
  end

  def update
    result = Braintree::Transaction.sale(
        :amount => params[:amount_to_add].to_f,
        :customer_id => customer.customer_cim_id,
        :tax_amount => (params[:amount_to_add].to_f / 11).round(2),
        :options => {
            :submit_for_settlement => true
        }
    )
    if result.success?
      logger.info "Added to #{params[:amount_to_add].to_f} to #{customer.first_name} #{customer.last_name} (#{customer.customer_cim_id})"
      customer.store_credit.add_credit(params[:amount_to_add].to_f)
      redirect_to profile_store_credit_path
      # , :notice => "Successfully updated store credit."
    else
      result.errors.each do |error|
        puts error.message
        # @store_credit.errors.add(:base, error.message)
        render :show, :notice => error.message
      end
    end
  end

  # def update
  #   @store_credit.process_braintree_payment(customer.customer_cim_id,params[:amount_to_add])
  #   if @store_credit.errors.empty?
  #     logger.info "Added to #{params[:amount_to_add].to_f} to #{customer.first_name} #{customer.last_name} (#{customer.customer_cim_id})"
  #     customer.store_credit.add_credit(params[:amount_to_add].to_f)
  #     redirect_to myaccount_store_credit_path
  #     # , :notice => "Successfully updated store credit."
  #   else
  #     render :terms
  #   end
  # end

  private

  def customer
    @customer ||= User.includes(:store_credit).find(current_user.id)
  end


end