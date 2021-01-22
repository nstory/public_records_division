class DownloadAppealYears
  include Capybara::DSL

  URL = "https://www.sec.state.ma.us/AppealsWeb/AppealsStatus.aspx"
  DATE_FORMAT = "%m/%d/%Y"

  def initialize(output_dir:, start_year:)
    @output_dir = output_dir
    @start_year = start_year
  end

  def download
    (@start_year.to_i .. Date.today.year).each do |year|
      (1 .. 12).each do |month|
        start_date = Date.new(year, month, 1)
        end_date = Date.new(year, month, -1)
        download_month(start_date, end_date)
      end
    end
  end

  private
  def download_month(start_date, end_date)
    # only download if file doesn't already exist
    file = "#{@output_dir}/#{start_date}_#{end_date}.html"
    return if File.exist?(file)

    $logger.info "downloading #{file}"

    # search for all cases in this year, and save HTML of results page
    visit URL
    page.find("#ddlDateType").select("Initial opened")
    page.find("#txtDateFrom").fill_in(with: start_date.strftime(DATE_FORMAT))
    page.find("#txtDateTo").fill_in(with: end_date.strftime(DATE_FORMAT))
    page.find("#BtnSearchAppeal").click
    page.find("#LblTotalAppeal", wait: 60) # wait for page to load
    IO.write(file, page.source)
  end
end
