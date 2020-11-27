require 'bundler/setup'
require 'csv'
require 'date'
require 'logger'

# require all gems in Gemfile
Bundler.require(:default)

# require all my code
Dir.glob("lib/*.rb") do |f|
  require_relative f
end

class PublicRecordsDivision
  def initialize
    Capybara.run_server = false
    Capybara.current_driver = :selenium_chrome_headless
    $logger = Logger.new(STDERR)
  end

  def details
    puts [
    "Record Number", "Agency name", "Nature of request", "Detail summary of request",
    "Request received", "Response provided", "Record provided",
    "Days until records provided",
    "Number of hours to fulfill request", "Number of minutes to fulfill request",
    "Processing fee charged",
    "Fee petitions submitted", "Request appealed",
    "Time required to comply with orders", "Court proceedings related to the response"
    ].to_csv

    Detail.all.each do |d|
      puts [
        d.record_number,
        d.agency_name,
        d.nature_of_request,
        d.detail_summary_of_request,
        d.request_received,
        d.response_provided,
        d.record_provided,
        d.days_until_records_provided,
        d.number_of_hours_to_fulfill_request,
        d.minutes_to_fulfill_request,
        d.processing_fee_charged.sub(/\.*/, "").gsub(/[^\d]/, "").to_i,
        d.fee_petitions_submitted,
        d.request_appealed,
        d.time_required_to_comply_with_orders,
        d.court_proceedings_related_to_the_response
      ].to_csv
    end
  end

  def request_table_rows
    puts %w{agency_name nature_of_request request_date response_date record_no}.to_csv
    RequestTableRow.all.each do |r|
      puts [
        r.agency_name,
        r.nature_of_request,
        r.request_date,
        r.response_date,
        r.record_no
      ].to_csv
    end
  end

  def appeal_table_rows
    puts AppealTableRow.new.to_h.keys.to_csv
    AppealTableRow.all.each do |atr|
      puts atr.to_h.values.to_csv
    end
  end

  def appeal_details
    puts AppealDetail.new.to_h.keys.to_csv
    AppealDetail.all.each do |atr|
      puts atr.to_h.values.to_csv
    end
  end

  def median_minutes_by_month
    puts ["month", "median_minutes_to_fulfill"].to_csv
    Detail.all
      .group_by(&:request_month)
      .select { |k,v| k >= "2017-01" && k <= "2019-12" }
      .sort_by { |k,v| k }
      .each do |rm, ds|
      a = ds.map(&:minutes_to_fulfill_request).reject { |m| m == 0 }.sort
      puts [rm, a[a.count/2]].to_csv
    end
  end

  def download_appeal_details
    ad = AppealsDatabase.new
    system("mkdir", "-p", "appeal_details")
    AppealTableRow.all.map(&:case_no).each do |cn|
      next if cn == "20160584" # :shrug:
      filename = "appeal_details/#{cn}.html"
      if !File.exist?(filename)
        $logger.info("requesting #{cn}")
        src = ad.fetch(cn)
        IO.write(filename, src)
        sleep 1 # be polite
      end
    end
  end

  def download_request_details
    system("mkdir", "-p", "request_details")
    rd = RequestDatabase.new
    RequestTableRow.all.sort_by(&:record_no).reverse.each do |row|
      filename = "request_details/#{row.record_no}"
      next unless /2019|2020/ =~ row.request_date
      if !File.exist?(filename)
        $logger.info("requesting #{row.record_no}")
        src = rd.request_details(row.record_no)
        IO.write(filename, src)
        sleep 1 # be polite
      end
    end
  end

  def download_tables
    system("mkdir", "-p", "request_tables")
    rd = RequestDatabase.new
    Date.today.downto(Date.new(2017, 1, 1)).each do |date|
      filename = "request_tables/#{date.iso8601}.html"
      if !File.exist?(filename)
        $logger.info("requesting #{date.iso8601}")
        page_source = rd.request_table(date, date)
        IO.write filename, page_source
        sleep 1 # be polite
      end
    end
  end

  def download_appeal_files
    last_file = 17579
    last_file.downto(1).each do |file_num|
      dir = "appeal_files/#{file_num}"
      next if Dir.exist?(dir)
      `mkdir #{dir} && cd #{dir} && curl 'https://www.sec.state.ma.us/AppealsWeb/Download.aspx?DownloadPath=#{file_num}'    -H 'authority: www.sec.state.ma.us'    -H 'pragma: no-cache'    -H 'cache-control: no-cache'    -H 'upgrade-insecure-requests: 1'    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36'    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'    -H 'sec-fetch-site: same-origin'    -H 'sec-fetch-mode: navigate'    -H 'sec-fetch-user: ?1'    -H 'sec-fetch-dest: document'    -H 'referer: https://www.sec.state.ma.us/AppealsWeb/AppealStatusDetail.aspx?AppealNo=PvVX7Cx91FYxS6rSIsp2Vg%3d%3d'    -H 'accept-language: en-US,en;q=0.9'    -H 'cookie: visid_incap_2233578=4KX76TAVQHyvt5E4Tnz2UOot4F4AAAAAQUIPAAAAAABDNw+mjOPuKZi/sMoek4KN; _ga=GA1.3.1036956518.1591750124; visid_incap_2174404=8UE7dAOzREe9dY3HE9vi3O6a614AAAAAQUIPAAAAAAAX/ZuTk1RsERqOK5PgP+e5; visid_incap_2224066=oCOfzYulQd6g1y5V56A4uKfc414AAAAAQkIPAAAAAADuNeQUTratsRY/jTQ+PrvT; ASP.NET_SessionId=xmgusub0pwflr4p1pgkvwsfk; nlbi_2233578=wcvzZzf/annpzU3hKbUY0wAAAAA6MZqsCmGT1YwpYumHyXxd; incap_ses_490_2233578=y0xIMg2BvglVBtWXqNTMBpfAtl8AAAAAWJITcjhjkkH6hcaSsU73yg=='    --compressed -J --remote-name`
    end
  end

  def console
    binding.pry
  end
end

prd = PublicRecordsDivision.new
prd.send(ARGV[0])
