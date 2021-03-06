require 'spec_helper'

describe "Products/terms" do
  before(:each) do
    product = assign(:products, stub_model(Product,
      :name => "Name",
      :description => "Description"
    ))
  end

  it "renders properties in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Description/)
  end
end
