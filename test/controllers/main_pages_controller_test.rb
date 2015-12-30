require 'test_helper'

class MainPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "Let Me Peekatchu-r Challenge"
  end

  test "should get about" do
    get :about
    assert_response :success
    assert_select "title", "Let Me Peekatchu-r Challenge"
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Let Me Peekatchu-r Challenge"
  end

  test "should get contact" do
    get :contact
    assert_response :success
    assert_select "title", "Let Me Peekatchu-r Challenge"
  end

end
