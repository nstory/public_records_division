class DownloadAppealDetails
  include Capybara::DSL

  def initialize(input_dir:, output_dir:)
    @input_dir = input_dir
    @output_dir = output_dir
  end

  def download
    AppealTableRow.all(@input_dir).each do |row|
      next if ENV['CASE_NO'] && row.case_no != ENV['CASE_NO']
      # 20160584 always errors out :shrug:
      download_details(row) unless row.case_no == "20160584"
    end
  end

  private
  def download_details(row)
    file = "#{@output_dir}/#{row.case_no}.json"
    if File.exist?(file)
      ad = AppealDetail.from_file(file)
      if ad.status == row.status && ad.determinations.count == row.determination_count
        return
      end
      $logger.info "updating existing detail #{row.case_no}"
    else
      $logger.info "downloading new detail #{row.case_no}"
    end

    visit row.url
    as = page.find_all("input").select { |i| /btnDeter/ =~ i['name'] }
    determinations = as.map { |a| fetch_determination(row.url, a) }
    json = JSON.generate(source: page.source, determinations: determinations)
    IO.write(file, json)
  end

  def fetch_determination(url, a)
    form = a.ancestor("form")
    inputs = form.all('input[type="hidden"]', visible: :all)
    params = inputs.map { |i| [i['name'], i['value']] }.to_h
    params["#{a['name']}.x"] = "7"
    params["#{a['name']}.y"] = "5"
    body = URI.encode_www_form(params)
    cookies = page.driver.browser.manage.all_cookies
    cookie_header = 'cookie: ' + cookies.map { |c| "#{c[:name]}=#{c[:value]}" }.join("; ")
    response = `curl "#{url}" -H '#{cookie_header}' --data-raw '#{body}'`
    if /DownloadPath=(\d+)/.match(response)
      $1
    else
      nil
    end
  end
end
