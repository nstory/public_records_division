class GenerateAppealsCsv
  MAPPING = {
    case_type: ->(ad) { ad.case_type },
    case_subtype: ->(ad) { ad.case_subtype },
    status: ->(ad) { ad.status },
    case_no: ->(ad) { ad.case_no },
    requester: ->(ad) { ad.requester },
    custodian: ->(ad) { ad.custodian },
    req_rec_date: ->(ad) { ad.req_rec_date },
    resp_prov_date: ->(ad) { ad.resp_prov_date },
    fees: ->(ad) { ad.fees },
    petitions: ->(ad) { ad.petitions },
    comply: ->(ad) { ad.comply },
    date_opened: ->(ad) { ad.date_opened },
    date_closed: ->(ad) { ad.date_closed },
    reconsider_open_date: ->(ad) { ad.reconsider_open_date },
    reconsider_close_date: ->(ad) { ad.reconsider_close_date },
    in_cam_open_date: ->(ad) { ad.in_cam_open_date },
    in_cam_close_date: ->(ad) { ad.in_cam_close_date },
    request_to_court: ->(ad) { ad.request_to_court },
    determination_count: ->(ad) { ad.determinations.count },
    url: ->(ad) { ad.url },
  }


  def initialize(details_dir:)
    @details_dir = details_dir
  end

  def call
    puts MAPPING.keys.to_csv
    AppealDetail.all(@details_dir).each do |ad|
      puts MAPPING.values.map { |l| l.call(ad) }.to_csv
    end
  end
end
