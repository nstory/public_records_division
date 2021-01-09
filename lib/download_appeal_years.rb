class DownloadAppealYears
  include Capybara::DSL

  URL = "https://www.sec.state.ma.us/AppealsWeb/AppealsStatus.aspx"

  def initialize(output_dir:, start_year:)
    @output_dir = output_dir
    @start_year = start_year
  end

  def download
    (@start_year.to_i .. Date.today.year).each do |year|
      download_year(year)
    end
  end

  private
  def download_year(year)
    # only download if file doesn't already exist
    file = "#{@output_dir}/#{year}.html"
    return if File.exist?(file)

    $logger.info "downloading #{year}"

    # search for all cases in this year, and save HTML of results page
    visit URL
    page.find("#DdlYear").select(year)
    page.find("#BtnSearchAppeal").click
    page.find("#LblTotalAppeal", wait: 60) # wait for page to load
    IO.write(file, page.source)
  end
end
