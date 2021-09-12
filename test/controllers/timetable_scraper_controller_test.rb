require "test_helper"

class TimetableScraperControllerTest < ActionDispatch::IntegrationTest
  test "should get scrape" do
    get timetable_scraper_scrape_url
    assert_response :success
  end
end
