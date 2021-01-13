class DownloadAppealYears
  include Capybara::DSL

  URL = "https://www.sec.state.ma.us/AppealsWeb/AppealsStatus.aspx"

  def initialize(output_dir:, start_year:)
    @output_dir = output_dir
    @start_year = start_year
  end

  def download
    (@start_year.to_i .. Date.today.year).each do |year|
      ["Appeal", "Fee Petition", "Time Petition"].each do |case_type|
        download_year(case_type, year)
      end
    end
  end

  private
  def download_year(case_type, year)
    # only download if file doesn't already exist
    file = "#{@output_dir}/#{year}_#{case_type.gsub(' ', '_')}.html"
    return if File.exist?(file)

    $logger.info "downloading #{file}"

    # search for all cases in this year, and save HTML of results page
    visit URL
    page.find("#ddlCaseType").select(case_type)
    page.find("#DdlYear").select(year)
    page.find("#BtnSearchAppeal").click
    page.find("#LblTotalAppeal", wait: 60) # wait for page to load
    IO.write(file, page.source)
  end
end
