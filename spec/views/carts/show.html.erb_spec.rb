require 'rails_helper'

RSpec.describe "carts/terms", type: :view do
  before(:each) do
    @cart = assign(:cart, Cart.create!(
      :user_id => 1,
      :customer_id => 2
    ))
  end

  it "renders properties in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
