require 'test_helper'

class FingerprintsControllerTest < ActionController::TestCase
  setup do
    @fingerprint = fingerprints(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fingerprints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fingerprint" do
    assert_difference('Fingerprint.count') do
      post :create, fingerprint: {  }
    end

    assert_redirected_to fingerprint_path(assigns(:fingerprint))
  end

  test "should show fingerprint" do
    get :show, id: @fingerprint
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fingerprint
    assert_response :success
  end

  test "should update fingerprint" do
    patch :update, id: @fingerprint, fingerprint: {  }
    assert_redirected_to fingerprint_path(assigns(:fingerprint))
  end

  test "should destroy fingerprint" do
    assert_difference('Fingerprint.count', -1) do
      delete :destroy, id: @fingerprint
    end

    assert_redirected_to fingerprints_path
  end
end
