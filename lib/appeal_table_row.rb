AppealTableRow = Struct.new(:case_no, :opened, :extended_deadline, :closed, :type, :sub_type, :status, :requester, :custodian, :url, :determination_count) do
  HEADERS = ["Case No.", "Opened", "Extended Deadline", "Closed", "Type", "Sub-type", "Status", "Requester", "Custodian"]
  def self.all(dir)
    Dir.glob("#{dir}/*.html").sort.reverse.lazy.flat_map do |f|
      html = Nokogiri.HTML(IO.read(f))
      headers = html.css(".GridHeader th").map(&:text)
      html.css(".GridRow, .GridAltRow").map do |row|
        row_values = row.css("th,td").map { |n| n.text.gsub("\u00A0", " ").strip }
        values = HEADERS.map do |name|
          idx = headers.index(name)
          if idx
            row_values[idx]
          else
            ""
          end
        end
        new(*values, parse_url(row), parse_determination_count(row))
      end
    end
  end

  private
  def self.parse_url(row)
    a = row.at_css("a")
    return nil unless a
    "https://www.sec.state.ma.us/AppealsWeb/#{a['href']}"
  end

  def self.parse_determination_count(row)
    row.css('input[type="image"]').count
  end
end
