require 'webdrivers'
require 'bundler'
Bundler.require

Kimurai.configure do |config|
  config.selenium_chrome_path = ENV["SELENIUM_CHROME_PATH"].presence || "/usr/bin/chromium-browser"
  config.chromedriver_path = ENV["CHROMEDRIVER_PATH"].presence || "/usr/bin/chromedriver"
end

class EngageTimetableScraper < Kimurai::Base
  @name = "engage_timetable_scraper"
  @engine = :selenium_chrome # Use selenium_chrome instead of the default mechanize
  @start_urls = ["https://avenorcollegeportal.engagehosted.com/Login.aspx"]

  def parse(response, url:, data: {})
    Capybara.default_max_wait_time = 20 # Wait up to 10 seconds for async processes to complete

    regexp = /<strong>(?<name>[\w\s\d]*)<\/strong><br>(?<start_time>\d{2}:\d{2}) - (?<end_time>\d{2}:\d{2})<br>(?<subject>[a-zA-Z0-9À-žȘșȚț\s]*)<br>(?<teacher>[a-zA-Z0-9À-žȘșȚț\s,]*)<br>(?<room>\w \d\.\d)<br>/
    timetable_xpath = '//table[@id="tblTimeTable_ctl00_PageContent_apTimetable_content_pupilTimetable"]'

    browser.fill_in 'ctl00$PageContent$loginControl$txtUN', with: data[:username] # Username
    browser.fill_in 'ctl00$PageContent$loginControl$txtPwd', with: data[:password] # Password
    browser.click_on 'Login'
    browser.click_on 'View Details'

    browser.click_on 'Timetable'

    # Get tbody from browser response and choose rows Monday – Sunday

    # Mechanize version
    # @rows = browser.find(timetable_xpath).native.children[2..8]

    # Selenium version
    @rows = Nokogiri::HTML(browser.find(timetable_xpath)['outerHTML']).xpath('//tbody').children[1..7]

    # Raise error if there are no rows found (i.e. the table was not found)
    raise StandardError.new 'Timetable is empty/Timetable header not selected' if @rows.nil? # Timetable header not selected
    
    @rows = @rows.map do |row|

      @lessons = row.children.xpath('descendant::span[@class="ttLessonText"]').map do |lesson|
        lesson = CGI.unescapeHTML(lesson.inner_html)
        if lesson.match? regexp
          m = lesson.match regexp
          {name: m[1], start_time: m[2], end_time: m[3], subject: m[4], teacher: m[5], room: m[6]}
        else
          raise RegexpError, "Lesson does not match regex expression."
        end
      end

      { day: row.children[1].text, lessons: @lessons }

    end

    # register_results(@rows)

    Lesson.destroy_all
    
    @rows.each do |row|
      row[:lessons].each do |lesson|
        Lesson.create!({
          name: lesson[:subject], 
          weekday: Date.parse(row[:day]).wday,
          start_time: lesson[:start_time],
          end_time: lesson[:end_time],
          teacher: lesson[:teacher],
          room: lesson[:room]
        })
      end
    end

  end

  # def register_results(results)
  # end

end
