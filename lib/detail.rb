Detail = Struct.new(
  :record_number, :agency_name, :nature_of_request,
  :detail_summary_of_request, :request_received, :response_provided,
  :record_provided, :number_of_hours_to_fulfill_request,
  :processing_fee_charged, :fee_petitions_submitted,
  :request_appealed, :time_required_to_comply_with_orders,
  :court_proceedings_related_to_the_response,
  keyword_init: true
) do

  def days_until_records_provided
    received_date = parse_date(request_received)
    record_date = parse_date(record_provided)
    return nil if !received_date
    return nil if !record_date
    return nil if record_date < received_date
    (record_date - received_date).to_i
  end

  def minutes_to_fulfill_request
    minutes = 0
    if (/(\d+) hour/i).match(number_of_hours_to_fulfill_request)
      minutes += $1.to_i*60
    end
    if (/(\d+) minute/i).match(number_of_hours_to_fulfill_request)
      minutes += $1.to_i
    end
    minutes
  end

  def request_month
    d = parse_date(request_received)
    return d.strftime("%Y-%m") if d
  end

  def self.all
    Enumerator.new do |y|
      from_html.each { |d| y << d }
      from_csv.each { |d| y << d }
    end.lazy.uniq(&:record_number)
  end

  def self.from_html
    Dir.glob("request_details/*").lazy.map do |f|
      doc = Nokogiri.HTML(IO.read(f))
      new(
        record_number: get_value(doc, "Record Number:"),
        agency_name: get_value(doc, "Agency name:"),
        nature_of_request: get_value(doc, "Nature of request:"),
        detail_summary_of_request: get_value(doc, "Detail summary of request"),
        request_received: get_value(doc, "Request received"),
        response_provided: get_value(doc, "Response provided"),
        record_provided: get_value(doc, "Record provided"),
        number_of_hours_to_fulfill_request: get_value(doc, "Number of hours to fulfill request"),
        processing_fee_charged: get_value(doc, "Processing fee charged"),
        fee_petitions_submitted: get_value(doc, "Fee petitions submitted"),
        request_appealed: get_value(doc, "Request appealed"),
        time_required_to_comply_with_orders: get_value(doc, "Time required to comply with orders"),
        court_proceedings_related_to_the_response: get_value(doc, "Court proceedings related to the response")
      )
    end
  end

  def self.from_csv
    CSV.foreach("prr.csv", headers: true, encoding: "ISO-8859-1").lazy.map do |row|
      h = row.to_h
      h.delete nil
      h.delete "final_court_decision"
      h = h.map { |k,v| [k, v ? v.strip : ""] }.to_h
      new(h)
    end
  end

  private
  def parse_date(str)
    Date.strptime(str, '%m/%d/%Y')
  rescue ArgumentError
    nil
  end

  def self.get_value(doc, key)
    n = doc.css("table td strong").select { |e| e.text.include?(key) }.first
    n.parent.parent.elements[1].text.strip if n
  end
end
