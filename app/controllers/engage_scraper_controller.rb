class EngageScraperController < ApplicationController
  def authorise
    render layout: 'devise'
  end
  
  def scrape
    if params[:email].present? && params[:password].present?
      flash.now[:notice] = "Information scraped successfully!"

      @response = EngagePupilScraper.parse!(:parse, url: 'https://avenorcollegeportal.engagehosted.com/Login.aspx', data: { username: params[:email], password: params[:password], current_user: current_user })
    else
      flash[:alert] = "Authorisation unsuccessful. Please authenticate before trying to scrape."
      redirect_to authorise_scrape_engage_path
    end

  rescue Capybara::ElementNotFound => e
    flash[:alert] = "Incorrect authentication details. Please try again."
    redirect_to authorise_scrape_engage_path

  rescue Exception => e
    flash.now[:alert] = e.to_s
  end
end
