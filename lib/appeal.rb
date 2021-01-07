Appeal = Struct.new(:detail, :files) do
  # attr_accessor :detail, :files

  def self.all
    no_to_files = case_no_to_files
    AppealDetail.all.map do |ad|
      a = Appeal.new
      a.detail = ad
      a.files = no_to_files.fetch(ad.case_no, [])
      a
    end
  end

  private
  def self.case_no_to_files
    AppealFile.all.inject(Hash.new {|h,k| h[k] = []}) { |h,af| af.case_nos.each { |cn| h[cn] << af }; h }
  end
end
