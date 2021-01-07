class Pdf
  def initialize(path)
    @path = path
  end

  # converts the PDF into text, running OCR if necessary
  def to_text
    # try simple pdftotext first
    text = text_from_pdf(@path)
    return text if text.length > 900

    # if that didn't work, ocr
    ocr_pdf(@path) do |ocr_path|
      text_from_pdf(ocr_path)
    end
  end

  private
  def ocr_pdf(path)
    Tempfile.create("Pdf_pdf") do |temp_pdf|
      system("ocrmypdf", "--skip-text", path, temp_pdf.path)
      yield temp_pdf.path
    end
  end

  def text_from_pdf(path)
    Tempfile.create do |tmp|
      system("pdftotext", "-layout", path, tmp.path)
      IO.read(tmp.path)
    end
  end
end
