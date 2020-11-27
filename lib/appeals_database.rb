require 'capybara/dsl'

class AppealsDatabase
  include Capybara::DSL

  URL = "https://www.sec.state.ma.us/AppealsWeb/AppealsStatus.aspx"

  def fetch(case_no)
    visit URL
    page.find("#txtCaseNumber").fill_in(with: case_no)
    page.find("#BtnSearchAppeal").click
    click_link case_no

    # make sure we're on the page
    page.find("#lblCaseNo", text: case_no)

    page.source
  end

  def pdf(appeal_no)
    encoded = URI.encode(appeal_no)
    `curl 'https://www.sec.state.ma.us/AppealsWeb/AppealStatusDetail.aspx?AppealNo=#{encoded}'    -H 'authority: www.sec.state.ma.us'    -H 'cache-control: max-age=0'    -H 'upgrade-insecure-requests: 1'    -H 'origin: https://www.sec.state.ma.us'    -H 'content-type: application/x-www-form-urlencoded'    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.135 Safari/537.36'    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'    -H 'sec-fetch-site: same-origin'    -H 'sec-fetch-mode: navigate'    -H 'sec-fetch-user: ?1'    -H 'sec-fetch-dest: document'    -H 'referer: https://www.sec.state.ma.us/AppealsWeb/AppealStatusDetail.aspx?AppealNo=Uvmw8Fv5JauGnzJOT83rcA%3d%3d'    -H 'accept-language: en-US,en;q=0.9'    -H 'cookie: visid_incap_2233578=4KX76TAVQHyvt5E4Tnz2UOot4F4AAAAAQUIPAAAAAABDNw+mjOPuKZi/sMoek4KN; _ga=GA1.3.1036956518.1591750124; visid_incap_2224066=oCOfzYulQd6g1y5V56A4uKfc414AAAAAQUIPAAAAAAAwFoPKhwFQx2Vr3sA+Vpz1; visid_incap_2174404=8UE7dAOzREe9dY3HE9vi3O6a614AAAAAQUIPAAAAAAAX/ZuTk1RsERqOK5PgP+e5; ASP.NET_SessionId=3jvuj5o1lydiaqs3fg4unqag; TS019ab495_77=081707b061ab2800ddf8803829cd02f8b09e991ab0ab83e4b80547a505099c4145759e7dde631c28737961aa15d049f708868c7f1f823800e05877a6b294597aa818f0c2a95fb55603e043a98dc88eaa332c2dd1b206a74a4b44d2cde74a35187ef96bce17b60d8b53f6835b04cc24f5; TSPD_101=081707b061ab280013b6e011f7544a6199404b6af70b514cc3e718460877203658ae97005cfef89343fb76512c6cc0e4:; TS019ab495=01cf497f1e713f9c053a66638369fc345cf00df5756261970ee71bace5e840e5644af6ea4f685763fe3ff37b84ee1389a08af353d0; nlbi_2233578=YYvkPGnQYmAAb+2uyftqoAAAAAAuzGebA++yXurvdPuBrnHI; _gid=GA1.3.303390779.1600960397; incap_ses_488_2233578=9ztVK0rEo2hwYB1TpLnFBvDAbF8AAAAAvfmy1IA+GUZd7xgHMBzpMw==; _gat=1'    --data-raw '__VIEWSTATE=QBNBJFPocN1UFvC4OFtSlCe4XcnDVPTPvASKGgnTgJFyQBrh29q7a9NQYKSRRGFwKRMntrJvms1UKg8CJkxpaR3FCqvrho81xlzSpC0IizAqjSL4OnrQz%2B1Z%2Fu4OANEAxfk59NfEnurUK3IQlVEC%2FwtzXypknPsraumhX21KN50wDhXcbQZOvonnJmU3GkYWptR4M2PHSGQPpAMuEl3SUjRl6TvKcbML66CAWYsaHPKYlLuDm1d%2BN8Nf2%2FqwVXA45MiaacgNvgurLDOHBE5jhpuBsBFWQ32c9sJXUnKef1J7pLVma01aUe%2FTgrhOjqixDx6rudj92vnS5Tj1Esu3McraTagv2l0duQThny8jRoZ%2B42RJpyvNom0FjvXnwWPv7NX%2FjEDfsAeCcuSVjvSENLJ5rNqmuMQTIl%2BsTPugtqEkFE6ureyW2QMRoljv0WCgTjHBDwaSBd0A8t4s6XvsvSD7Km%2F0%2FbG7irvxh2SUtqXdp7BoO%2FkPASB328EkryNY31YB2zCxCIs9N3w20oPhf%2Fi0xVbgzESCSsEOf0yDuElJNyR%2FbUD%2B2W%2B7sf60rFTs6vH5kdIz%2BX5APgqfc%2BgWsdhDfDkvSzbQcsl2gjwjoqavkD%2F8Nul%2BtFMxvNXvtRVMcF6caElJXa6a6n10uQQ5YgxHQwOtDCuunw2UCnBEtKfHHG%2BLLY9%2FP5xudgurUC2R&__VIEWSTATEGENERATOR=F4980BEC&__VIEWSTATEENCRYPTED=&__EVENTVALIDATION=dNA4mUimgTeMqKUE5NpcXRtQxf6%2F4xBusEwfsP4iZgCigue87E6uBlQjRwsI9NNqdrpGsarXyJyKhcey57bVJjBT6zjr2hNQMlpzMa0%2Fu%2FRqACPZgqmuJcZ3%2BLkpVkCSYR1lqVrpLKXcvis8qd0M9qYCtv1s%2F3WRYFWFksGeYQCWRzq2KVGG8PAGAdhcska%2F&RpterImagesList%24ctl00%24btnDetermination.x=10&RpterImagesList%24ctl00%24btnDetermination.y=5'    --compressed`
  end
end
