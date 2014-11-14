require 'test_helper'

class CombinationsControllerTest < ActionController::TestCase
  setup do
    @combination = combinations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:combinations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create combination" do
    assert_difference('Combination.count') do
      post :create, combination: { fingerprint_id: @combination.fingerprint_id, user_agent_id: @combination.user_agent_id }
    end

    assert_redirected_to combination_path(assigns(:combination))
  end

  test "should show combination" do
    get :show, id: @combination
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @combination
    assert_response :success
  end

  test "should update combination" do
    patch :update, id: @combination, combination: { fingerprint_id: @combination.fingerprint_id, user_agent_id: @combination.user_agent_id }
    assert_redirected_to combination_path(assigns(:combination))
  end

  test "should destroy combination" do
    assert_difference('Combination.count', -1) do
      delete :destroy, id: @combination
    end

    assert_redirected_to combinations_path
  end
end
