RequestTableRow = Struct.new(:agency_name, :nature_of_request, :request_date, :response_date, :record_no, keyword_init: true) do
  def self.all
    Dir.glob("request_tables/*.html").lazy.flat_map do |f|
      html = Nokogiri.HTML(IO.read(f))
      html.css("#MainContent_grdvResults tr.GridItem, #MainContent_grdvResults tr.GridAltItem").map do |row|
        values = row.css("th,td").map { |n| n.text.gsub("\u00A0", " ").strip }
        new(agency_name: values[0], nature_of_request: values[1], request_date: values[2], response_date: values[3], record_no: values[4])
      end
    end
  end
end
