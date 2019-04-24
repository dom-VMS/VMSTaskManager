require 'test_helper'

class ContentsControllerTest < ActionDispatch::IntegrationTest
  test "should get getting_started" do
    get contents_getting_started_url
    assert_response :success
  end

end
