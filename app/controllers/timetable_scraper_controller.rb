class TimetableScraperController < ApplicationController
  def scrape
    flash.now[:notice] = "Scraping Url..."
    @response = EngageTimetableScraper.parse!(:parse, url: 'https://avenorcollegeportal.engagehosted.com/Login.aspx', data: { username: 'fratilao@yahoo.com', password: 'olivleon23' })

    puts @response
  rescue Exception => e
    flash.now[:alert] = "Error: #{e}"
  end
end
