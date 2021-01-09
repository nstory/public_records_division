class DownloadAppealDownloads
  # this might need to be updated for this script to work
  HEADER =  'cookie: visid_incap_2233578=4KX76TAVQHyvt5E4Tnz2UOot4F4AAAAAQUIPAAAAAABDNw+mjOPuKZi/sMoek4KN; _ga=GA1.3.1036956518.1591750124; visid_incap_2174404=8UE7dAOzREe9dY3HE9vi3O6a614AAAAAQUIPAAAAAAAX/ZuTk1RsERqOK5PgP+e5; ASP.NET_SessionId=jdoyfnidrqex3krhxwmfvoeu; nlbi_2233578=CMXYck1G0W5wiA+s1oe+SgAAAADHJZscIj27xnsUz3KTutSh; visid_incap_2224066=us8BiTunSLGMXM2WHKivalVX718AAAAAQUIPAAAAAADHwrhOGfteSrFyxvyzweIT; incap_ses_358_2224066=n13lBC9alHth8jXNKt/3BFVX718AAAAAf7Gt8CKXYs56edBlqY2Xxw==; incap_ses_488_2233578=/ekXHq7Re3vKRCKvtLnFBg159V8AAAAAQRC+fwwawsnyak8n6TUJGA==; incap_ses_220_2233578=0dOuX8ZkWFG1jLDTCJkNAxSp9V8AAAAAUC6ByEsiOt8J27ZcBPKlqg==; incap_ses_1316_2233578=Sqk3YsfhSh3bOasIDl9DEiOw9V8AAAAAg78jD3IZuWWV0mlNTDziDA==; _gid=GA1.3.430722124.1610038864; incap_ses_358_2233578=xYIOLhTRjiMgHkQSLd/3BFJP918AAAAAX61PV1oe4kbNMkdkrOJoLA==; incap_ses_490_2233578=5rbaEg+xL03HRjiTr9TMBrlR+F8AAAAAk+2b/ezDv1PArLomulN2rw=='

  def initialize(input_dir:, output_dir:)
    @input_dir = input_dir
    @output_dir = output_dir
  end

  def download
    determinations.each do |d|
      dir = "#{@output_dir}/#{d}"
      next if Dir.exist?(dir) && !Dir.empty?(dir)

      $logger.info "download #{d}"

      url = "https://www.sec.state.ma.us/AppealsWeb/Download.aspx?DownloadPath=#{d}"
      system("mkdir", "-p", dir)
      `cd "#{dir}" && curl "#{url}" -H '#{HEADER}' --compressed -J --remote-name`
    end
  end

  private
  def determinations
    Enumerator.new do |y|
      AppealDetail.all(@input_dir).each do |ad|
        ad.determinations.each do |d|
          y << d
        end
      end
    end
  end
end
