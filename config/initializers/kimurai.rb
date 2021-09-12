require 'bundler'
Bundler.require

Kimurai.configure do |config|
  config.selenium_chrome_path = ENV["SELENIUM_CHROME_PATH"].presence || "/usr/bin/chromium-browser"
  config.chromedriver_path = ENV["CHROMEDRIVER_PATH"].presence || "/usr/bin/chromedriver"
end