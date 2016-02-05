require 'test_helper'

class AddressesControllerTest < ActionController::TestCase
  setup do
    @address = addresses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:addresses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create address" do
    assert_difference('Address.count') do
      post :create, address: { address1: @address.address1, address2: @address.address2, address_type_id: @address.address_type_id, addressable_id: @address.addressable_id, addressable_type: @address.addressable_type, alternative_phone: @address.alternative_phone, billing_default: @address.billing_default, city: @address.city, country_id: @address.country_id, default: @address.default, first_name: @address.first_name, last_name: @address.last_name, phone_id: @address.phone_id, state_id: @address.state_id, state_name: @address.state_name, zip_code: @address.zip_code }
    end

    assert_redirected_to address_path(assigns(:address))
  end

  test "should show address" do
    get :show, id: @address
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @address
    assert_response :success
  end

  test "should update address" do
    patch :update, id: @address, address: { address1: @address.address1, address2: @address.address2, address_type_id: @address.address_type_id, addressable_id: @address.addressable_id, addressable_type: @address.addressable_type, alternative_phone: @address.alternative_phone, billing_default: @address.billing_default, city: @address.city, country_id: @address.country_id, default: @address.default, first_name: @address.first_name, last_name: @address.last_name, phone_id: @address.phone_id, state_id: @address.state_id, state_name: @address.state_name, zip_code: @address.zip_code }
    assert_redirected_to address_path(assigns(:address))
  end

  test "should destroy address" do
    assert_difference('Address.count', -1) do
      delete :destroy, id: @address
    end

    assert_redirected_to addresses_path
  end
end
