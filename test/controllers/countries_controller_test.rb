require 'test_helper'

class CountriesControllerTest < ActionController::TestCase
  setup do
    @country = countries(:one)
  end

  test "should get terms" do
    get :terms
    assert_response :success
    assert_not_nil assigns(:countries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create country" do
    assert_difference('Country.count') do
      post :create, country: { abbreviation: @country.abbreviation, active: @country.active, name: @country.name, shipping_zone_id: @country.shipping_zone_id }
    end

    assert_redirected_to country_path(assigns(:country))
  end

  test "should terms country" do
    get :terms, id: @country
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @country
    assert_response :success
  end

  test "should update country" do
    patch :update, id: @country, country: { abbreviation: @country.abbreviation, active: @country.active, name: @country.name, shipping_zone_id: @country.shipping_zone_id }
    assert_redirected_to country_path(assigns(:country))
  end

  test "should destroy country" do
    assert_difference('Country.count', -1) do
      delete :destroy, id: @country
    end

    assert_redirected_to countries_path
  end
end
