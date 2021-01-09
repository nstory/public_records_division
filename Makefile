export APPEAL_YEARS_DIR=input/appeal_years
export APPEAL_DETAILS_DIR=input/appeal_details
export APPEAL_DOWNLOADS_DIR=input/appeal_downloads
export APPEAL_TEXT_DIR=input/appeal_text
export APPEALS_JSON_FILE=output/appeals.jsonl.gz
export DECISIONS_2020_FILE=output/decisions_2020.zip

.PHONY: $(APPEAL_YEARS_DIR) $(APPEAL_DETAILS_DIR) $(APPEAL_DOWNLOADS_DIR) $(APPEAL_TEXT_DIR) $(APPEALS_JSON_FILE) $(DECISIONS_2020_FILE) upload-downloads upload-appeals-json

all: $(APPEAL_YEARS_DIR) $(APPEAL_DETAILS_DIR) $(APPEAL_DOWNLOADS_DIR) $(APPEAL_TEXT_DIR) $(APPEALS_JSON_FILE)

clean:
	rm -rf output && mkdir output && touch output/.keep

clean-years:
	rm -f $(APPEAL_YEARS_DIR)/*.html

upload-downloads:
	cd $(APPEAL_DOWNLOADS_DIR) && aws s3 sync ./ 's3://wokewindows-data/appeals/' --acl public-read

upload-appeals-json:
	aws s3 cp $(APPEALS_JSON_FILE) "s3://wokewindows-data/"

$(DECISIONS_2020_FILE):
	ruby lib/public_records_division.rb decisions_2020

$(APPEALS_JSON_FILE):
	APPEAL_DETAILS_DIR=$(APPEAL_DETAILS_DIR) APPEAL_TEXT_DIR=$(APPEAL_TEXT_DIR) ruby lib/public_records_division.rb generate_appeals_jsonl | gzip > $(APPEALS_JSON_FILE)

$(APPEAL_YEARS_DIR):
	mkdir -p $(APPEAL_YEARS_DIR)
	OUTPUT_DIR=$(APPEAL_YEARS_DIR) START_YEAR=2014 ruby lib/public_records_division.rb download_appeal_years

$(APPEAL_DETAILS_DIR):
	mkdir -p $(APPEAL_DETAILS_DIR)
	INPUT_DIR=$(APPEAL_YEARS_DIR) OUTPUT_DIR=$(APPEAL_DETAILS_DIR) ruby lib/public_records_division.rb download_appeal_details

$(APPEAL_DOWNLOADS_DIR):
	mkdir -p $(APPEAL_DOWNLOADS_DIR)
	INPUT_DIR=$(APPEAL_DETAILS_DIR) OUTPUT_DIR=$(APPEAL_DOWNLOADS_DIR) ruby lib/public_records_division.rb download_appeal_downloads

$(APPEAL_TEXT_DIR):
	mkdir -p $(APPEAL_TEXT_DIR)
	INPUT_DIR=$(APPEAL_DOWNLOADS_DIR) OUTPUT_DIR=$(APPEAL_TEXT_DIR) ruby lib/public_records_division.rb textify_downloads
