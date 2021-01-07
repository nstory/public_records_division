class AppealFile
  attr_accessor :path

  def case_nos
    [*case_nos_from_text, case_no_from_filename].compact.uniq
  end

  def self.all
    Dir.glob("appeal_files/**/*")
      .select { |f| /\.pdf$/i =~ f }
      .map do |path|
        af = AppealFile.new
        af.path = path
        af
    end
  end

  def case_nos_from_text
    text.scan(%r{SPR([\do]{2})/([\do]{3,4})}i).map do |year,seq|
      year.gsub!(/o/i, "0")
      seq.gsub!(/o/i, "0")
      "20#{year}#{'%04d' % seq.to_i}"
    end.uniq
  end

  def case_no_from_filename
    filename = File.basename(path)
    if /^spr(\d{6})[^\d]/i =~ filename
      return "20#{$1}"
    elsif /^spr(\d{5})[^\d]/i =~ filename
      return "20#{$1[0...2]}0#{$1[2...5]}"
    elsif /^spr(\d{2})-(\d{3})[^\d]/i =~ filename
      return "20#{$1}0#{$2}"
    elsif /^spr(\d{2})-(\d{4})[^\d]/i =~ filename
      return "20#{$1}#{$2}"
    elsif /^(\d{5})[^\d]/ =~ filename
      return "20#{$1[0...2]}0#{$1[2...5]}"
    elsif /^(\d{6})[^\d]/ =~ filename
      return "20#{$1}"
    end
  end

  def text
    text_path = path.sub(/appeal_files/, "appeal_txt").sub(/pdf$/i, "txt")
    if File.exist?(text_path)
      IO.read(text_path)
    else
      ""
    end
  end
end
