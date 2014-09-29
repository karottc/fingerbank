require 'test_helper'

class DhcpVendorsControllerTest < ActionController::TestCase
  setup do
    @dhcp_vendor = dhcp_vendors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dhcp_vendors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dhcp_vendor" do
    assert_difference('DhcpVendor.count') do
      post :create, dhcp_vendor: { value: @dhcp_vendor.value }
    end

    assert_redirected_to dhcp_vendor_path(assigns(:dhcp_vendor))
  end

  test "should show dhcp_vendor" do
    get :show, id: @dhcp_vendor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dhcp_vendor
    assert_response :success
  end

  test "should update dhcp_vendor" do
    patch :update, id: @dhcp_vendor, dhcp_vendor: { value: @dhcp_vendor.value }
    assert_redirected_to dhcp_vendor_path(assigns(:dhcp_vendor))
  end

  test "should destroy dhcp_vendor" do
    assert_difference('DhcpVendor.count', -1) do
      delete :destroy, id: @dhcp_vendor
    end

    assert_redirected_to dhcp_vendors_path
  end
end
