require 'rails_helper'

RSpec.describe "variants/new", type: :view do
  before(:each) do
    assign(:variant, Variant.new(
      :variant_id => 1,
      :price => "9.99",
      :cost => "9.99"
    ))
  end

  it "renders new variant form" do
    render

    assert_select "form[action=?][method=?]", variants_path, "post" do

      assert_select "input#variant_product_id[name=?]", "variant[product_id]"

      assert_select "input#variant_price[name=?]", "variant[price]"

      assert_select "input#variant_cost[name=?]", "variant[cost]"
    end
  end
end
