require 'test_helper'

class DiscoverersControllerTest < ActionController::TestCase
  setup do
    @discoverer = discoverers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:discoverers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create discoverer" do
    assert_difference('Discoverer.count') do
      post :create, discoverer: {  }
    end

    assert_redirected_to discoverer_path(assigns(:discoverer))
  end

  test "should show discoverer" do
    get :show, id: @discoverer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @discoverer
    assert_response :success
  end

  test "should update discoverer" do
    patch :update, id: @discoverer, discoverer: {  }
    assert_redirected_to discoverer_path(assigns(:discoverer))
  end

  test "should destroy discoverer" do
    assert_difference('Discoverer.count', -1) do
      delete :destroy, id: @discoverer
    end

    assert_redirected_to discoverers_path
  end
end
