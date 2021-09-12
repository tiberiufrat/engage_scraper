class EngagePupilDetailsScraper < Kimurai::Base
  @name = "engage_pupil_details_scraper"
  @driver = :selenium_chrome
  @start_urls = ["https://avenorcollegeportal.engagehosted.com/Login.aspx"]

  def parse(response, url:, data: {})
    browser.fill_in 'ctl00$PageContent$loginControl$txtUN', with: data[:username] # Username
    browser.fill_in 'ctl00$PageContent$loginControl$txtPwd', with: data[:password] # Password
    browser.click_on 'Login'
    browser.click_on 'View Details'

    # Update response to current response after interaction with browser
    response = browser.current_response
  end
  
end
