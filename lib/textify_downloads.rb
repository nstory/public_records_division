class TextifyDownloads
  def initialize(input_dir:, output_dir:)
    @input_dir = input_dir
    @output_dir = output_dir
  end

  def call
    Dir.glob("#{@input_dir}/*/*.pdf").each do |pdf_file|
      txt_file = pdf_file.sub(@input_dir, @output_dir).sub(/pdf$/, "txt")
      next if File.exist?(txt_file)

      $logger.info "textify #{pdf_file}"
      text = Pdf.new(pdf_file).to_text
      system("mkdir", "-p", File.dirname(txt_file))
      IO.write(txt_file, text)
    end
  end
end
