require 'webdrivers'

class EngagePupilScraper < Kimurai::Base
  @name = "engage_pupil_scraper"
  @engine = :selenium_chrome # Use selenium_chrome instead of the default mechanize
  @start_urls = ["https://avenorcollegeportal.engagehosted.com/Login.aspx"]

  def parse(response, url:, data: {})
    Capybara.default_max_wait_time = 20 # Wait up to 20 seconds for async processes to complete

    browser.fill_in 'ctl00$PageContent$loginControl$txtUN', with: data[:username] # Username
    browser.fill_in 'ctl00$PageContent$loginControl$txtPwd', with: data[:password] # Password
    browser.click_on 'Login'
    puts 'Logged in'
    browser.click_on 'View Details'
    puts 'View details'

    puts 'Started getting timetable'
    get_timetable(data[:current_user])
    puts 'Started getting pupil details'
    get_pupil_details(data[:current_user])
  end

  # Get the timetable from Engage
  def get_timetable current_user
    # Declare regular expression and timetable xpath
    regexp = /<strong>(?<name>[\w\s\d]*)<\/strong><br>(?<start_time>\d{2}:\d{2}) - (?<end_time>\d{2}:\d{2})<br>(?<subject>[a-zA-Z0-9À-žȘșȚț\s]*)<br>(?<teacher>[a-zA-Z0-9À-žȘșȚț\s,]*)<br>(?<room>\w \d\.\d)<br>/
    timetable_xpath = '//table[@id="tblTimeTable_ctl00_PageContent_apTimetable_content_pupilTimetable"]'
    
    puts 'Clicked on Timetable'
    browser.click_on 'Timetable'

    # Get tbody from browser response and choose rows Monday – Sunday
    # Selenium version
    @rows = Nokogiri::HTML(browser.find(timetable_xpath)['outerHTML']).xpath('//tbody').children[1..7]
    puts "Got rows: #{@rows}"

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

    puts "Mapped rows: #{@rows}"

    puts "Started registering"
    register_timetable(@rows, current_user)
  end

  # Regsiter the new classes in the timetable
  def register_timetable rows, user
    Lesson.where(user: user).destroy_all
    
    rows.each do |row|
      row[:lessons].each do |lesson|
        Lesson.create!({
          name: lesson[:subject], 
          weekday: Date.parse(row[:day]).wday,
          start_time: lesson[:start_time],
          end_time: lesson[:end_time],
          teacher: lesson[:teacher],
          room: lesson[:room],
          user: user
        })
      end
    end
  end

  # Get pupil details from Engage
  def get_pupil_details current_user
    puts 'Clicked on Pupil Details'
    browser.click_on 'Pupil Details'

    @rows_text = Nokogiri.HTML(browser.find('//div[@id="ctl00_PageContent_apPupilDetails_content_upPupilDetails"]/table[@class="info left"]/tbody')['outerHTML'])
    puts "Got rows_text: #{@rows_text}"
    
    # get table headers
    headers = []
    @rows_text.xpath('//*/tbody/tr/th').each do |th|
      headers << th.text
    end

    # get table rows
    rows = {}
    @rows_text.xpath('//*/tbody/tr').each_with_index do |row, i|
      row.xpath('td').each_with_index do |td, j|
        rows[headers[2*i+j]] = td.text.strip
      end
    end

    puts "Got rows: #{rows}"

    # Image
    image_path = Nokogiri::HTML.fragment(browser.find('//img[@id="ctl00_PageContent_pupilInfo_imgPupilImage"]')['outerHTML']).child.attributes['src'].value
    image_url = 'https://avenorcollegeportal.engagehosted.com/' + image_path

    puts "Got image: #{image_url}"

    puts 'Updating pupil details'
    update_pupil_details(current_user, image_url, rows)

  end

  # Update pupil details
  def update_pupil_details user, image_url, rows
    unless form = Form.find_by(name: rows["Form"])
      form = Form.create!(name: rows["Form"], form_tutor: rows["Form Tutor"])
    end

    user.update!({ 
      first_name: rows["First Name"],
      last_name: rows["Surname"],
      gender: rows["Gender"],
      house: rows["House"],
      birth_date: Date.parse(rows["Date of Birth"]),
      year: rows["Year Group"].split[1].to_i,
      image: image_url,
      form: form
    })
  end

end
