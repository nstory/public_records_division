class GenerateAppealsJsonl
  def initialize(details_dir:, text_dir:)
    @details_dir = details_dir
    @text_dir = text_dir
  end

  def call
    AppealDetail.all(@details_dir).each do |ad|
      h = ad.to_h
      h["files"] = ad.determinations.map { |d| parse_files(d) }.compact
      puts h.to_json
    end
  end

  private
  def parse_files(download_number)
    txt_file = Dir.glob("#{@text_dir}/#{download_number}/*.txt").first
    return nil if !txt_file
    {
      path: txt_file.sub("#{@text_dir}/", "").sub(/txt$/, "pdf"),
      text: IO.read(txt_file)
    }
  end
end
