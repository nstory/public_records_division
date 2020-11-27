require 'capybara/dsl'

class RequestDatabase
  include Capybara::DSL

  SEARCH_REQUESTS_URL = "https://www.sec.state.ma.us/RequestSearchWeb/Webpages/SearchResultsDetail.aspx"

  def request_table(date1, date2)
    visit SEARCH_REQUESTS_URL
    d1v = date1.strftime("%m/%d/%Y")
    d2v = date2.strftime("%m/%d/%Y")
    page.find("#MainContent_ddlDateType").select("Request Received Date")
    page.find("#MainContent_txtDateFrom").fill_in(with: d1v)
    page.find("#MainContent_txtDateTo").fill_in(with: d2v)
    page.find("#MainContent_btnSearch").click
    page.source
  end

  def request_details(record_no)
    visit SEARCH_REQUESTS_URL
    page.find("#MainContent_txtRcdNumber").fill_in(with: record_no)
    page.find("#MainContent_btnSearch").click
    click_link record_no

    # make sure we're on the page
    page.find("h3", text: "Public Records Request Details")

    page.source
  end
end
