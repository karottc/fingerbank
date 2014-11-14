require 'test_helper'

class MacVendorsControllerTest < ActionController::TestCase
  setup do
    @mac_vendor = mac_vendors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mac_vendors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mac_vendor" do
    assert_difference('MacVendor.count') do
      post :create, mac_vendor: { mac: @mac_vendor.mac, name: @mac_vendor.name }
    end

    assert_redirected_to mac_vendor_path(assigns(:mac_vendor))
  end

  test "should show mac_vendor" do
    get :show, id: @mac_vendor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mac_vendor
    assert_response :success
  end

  test "should update mac_vendor" do
    patch :update, id: @mac_vendor, mac_vendor: { mac: @mac_vendor.mac, name: @mac_vendor.name }
    assert_redirected_to mac_vendor_path(assigns(:mac_vendor))
  end

  test "should destroy mac_vendor" do
    assert_difference('MacVendor.count', -1) do
      delete :destroy, id: @mac_vendor
    end

    assert_redirected_to mac_vendors_path
  end
end
