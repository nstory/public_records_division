AppealTableRow = Struct.new(:case_no, :opened, :closed, :type, :sub_type, :status, :requester, :custodian) do
  def self.all
    Dir.glob("appeals_tables/*.html").sort.reverse.lazy.flat_map do |f|
      html = Nokogiri.HTML(IO.read(f))
      html.css(".GridRow, .GridAltRow").map do |row|
        values = row.css("th,td").map { |n| n.text.gsub("\u00A0", " ").strip }
        new(*values[0...8])
      end
    end
  end
end
