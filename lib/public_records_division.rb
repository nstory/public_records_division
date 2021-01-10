require 'bundler/setup'
require 'capybara/dsl'
require 'csv'
require 'date'
require 'logger'

# require all gems in Gemfile
Bundler.require(:default)

# require all my code
Dir.glob("#{__dir__}/*.rb") do |f|
  require_relative f unless /public_records_division.rb/ =~ f
end

class PublicRecordsDivision
  def initialize
    Capybara.run_server = false
    Capybara.current_driver = :selenium_chrome_headless
    # Capybara.current_driver = :selenium_chrome
    $logger = Logger.new(STDERR)
  end

  def console
    binding.pry
  end

  def download_appeal_years
    DownloadAppealYears.new(output_dir: ENV.fetch("OUTPUT_DIR"), start_year: ENV.fetch("START_YEAR")).download
  end

  def download_appeal_details
    DownloadAppealDetails.new(input_dir: ENV.fetch("INPUT_DIR"), output_dir: ENV.fetch("OUTPUT_DIR")).download
  end

  def download_appeal_downloads
    DownloadAppealDownloads.new(
      input_dir: ENV.fetch("INPUT_DIR"),
      output_dir: ENV.fetch("OUTPUT_DIR")
    ).download
  end

  def textify_downloads
    TextifyDownloads.new(
      input_dir: ENV.fetch("INPUT_DIR"),
      output_dir: ENV.fetch("OUTPUT_DIR")
    ).call
  end

  def generate_appeals_jsonl
    GenerateAppealsJsonl.new(
      details_dir: ENV.fetch("APPEAL_DETAILS_DIR"),
      text_dir: ENV.fetch("APPEAL_TEXT_DIR")
    ).call
  end

  def decisions_2020
    ids = AppealDetail.all(ENV.fetch("APPEAL_DETAILS_DIR"))
      .select { |ad| /^2020/ =~ ad.case_no }
      .flat_map(&:determinations)
      .to_a
    Dir.mktmpdir do |tmpdir|
      ids.each do |id|
        Dir.glob("#{ENV.fetch('APPEAL_DOWNLOADS_DIR')}/#{id}/*").each do |f|
          system('cp', f, tmpdir)
        end
      end
      zip_file_path = File.absolute_path(ENV.fetch("DECISIONS_2020_FILE"))
      `cd #{tmpdir} && zip -r #{zip_file_path} ./`
    end
  end
end

prd = PublicRecordsDivision.new
prd.send(ARGV[0])
