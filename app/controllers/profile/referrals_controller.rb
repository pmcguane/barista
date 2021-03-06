class Profile::ReferralsController < ApplicationController

  def index
    @referral  = Referral.new
    @referrals = current_user.referrals
  end

  def create
    @referral = current_user.referrals.new(allowed_params)
    @referral.referral_type_id = ReferralType::DIRECT_WEB_FORM_ID
    if @referral.save
      redirect_to profile_referrals_url, notice: 'Successfully created referral.'
    else
      @referrals = current_user.referrals
      render :index
    end
  end

  def update
    @referral = current_user.referrals.find(params[:id])
    if @referral.update_attributes(allowed_params)
      redirect_to myaccount_referrals_url, notice: 'Successfully updated referral.'
    else
      @referrals = current_user.referrals
      render :index
    end
  end

  private

    def allowed_params
      params.require(:referral).permit(:email, :name)
    end

end