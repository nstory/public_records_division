AppealDetail = Struct.new(
  :case_type, :case_subtype, :status, :case_no, :requester, :custodian,
  :req_rec_date, :resp_prov_date, :fees, :petitions, :comply, :date_opened,
  :date_closed, :reconsider_open_date, :reconsider_close_date, :in_cam_open_date,
  :in_cam_close_date, :request_to_court, :appeal_no, :determinations,
  keyword_init: true
) do

  MAPPING = {
    "lblCaseType" => :case_type,
    "lblCaseSubType" => :case_subtype,
    "lblStatus" => :status,
    "lblCaseNo" => :case_no,
    "lblRequester" => :requester,
    "lblCustodian" => :custodian,
    "lblReqRecDate" => :req_rec_date,
    "lblRespProvDate" => :resp_prov_date,
    "lblFees" => :fees,
    "lblPetitions" => :petitions,
    "lblComply" => :comply,
    "lblDateOpened" => :date_opened,
    "lblDateClosed" => :date_closed,
    "lblReconsiderOpenDt" => :reconsider_open_date,
    "lblReconsiderCloseDt" => :reconsider_close_date,
    "lblInCamOpenDt" => :in_cam_open_date,
    "lblInCamCloseDt" => :in_cam_close_date,
    "lblReqToCourt" => :request_to_court,
  }

  def url
    "https://www.sec.state.ma.us/AppealsWeb/AppealStatusDetail.aspx?AppealNo=#{URI.encode_www_form_component(appeal_no)}"
  end

  def self.all(input_dir)
    Dir.glob("#{input_dir}/*.json").lazy.map do |f|
      from_file(f)
    end
  end

  def self.from_file(file)
      json = JSON.parse(IO.read(file))
      doc = Nokogiri.HTML(json["source"])
      h = {}
      doc.css('span[id^="lbl"]').each do |e|
        key = MAPPING[e['id']]
        h[key] = e.text.strip if key
      end
      h[:appeal_no] = parse_appeal_no(doc)
      h[:determinations] = json['determinations']
      # binding.pry unless h[:case_no]
      new(h)
  end

  private
  def self.parse_appeal_no(doc)
    doc.css("form").each do |form|
      if /(?<=AppealNo=)(.*)/ =~ form[:action]
        return URI.decode($1)
      end
    end
    nil
  end
end
