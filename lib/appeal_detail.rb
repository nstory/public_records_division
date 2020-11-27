AppealDetail = Struct.new(
  :case_type, :case_subtype, :status, :case_no, :requester, :custodian,
  :req_rec_date, :resp_prov_date, :fees, :petitions, :comply, :date_opened,
  :date_closed, :reconsider_open_date, :reconsider_close_date, :in_cam_open_date,
  :in_cam_close_date, :request_to_court,
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

  def self.all
    Dir.glob("appeal_details/*.html").lazy.map do |f|
      doc = Nokogiri.HTML(IO.read(f))
      h = {}
      doc.css('span[id^="lbl"]').each do |e|
        key = MAPPING[e['id']]
        h[key] = e.text.strip if key
      end
      new(h)
    end
  end
end
