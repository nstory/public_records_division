class GenerateDeterminationsZip
  def initialize(determinations_zip:, details_dir:, downloads_dir:)
    @determinations_zip = determinations_zip
    @details_dir = details_dir
    @downloads_dir = downloads_dir
  end

  def call
    Dir.mktmpdir do |tmpdir|
      # create a dir for each appeal and copy in its files
      AppealDetail.all(@details_dir).each do |ad|
        ad_dir = "#{tmpdir}/#{ad.case_no}"
        unless ad.determinations.empty?
          system("mkdir", "-p", ad_dir)
        end
        ad.determinations.each do |d|
          det_dir = "#{@downloads_dir}/#{d}"
          Dir.glob("#{det_dir}/*").each do |f|
            system("cp", f, ad_dir)
          end
        end
      end

      # zip the dir
      zip_file_path = File.absolute_path(@determinations_zip)
      `cd #{tmpdir} && zip -r #{zip_file_path} ./`
    end
  end
end
