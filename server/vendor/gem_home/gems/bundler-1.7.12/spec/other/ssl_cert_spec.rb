require 'spec_helper'
require 'bundler/ssl_certs/certificate_manager'

describe "SSL Certificates", :rubygems_master do
  it "are up to date with Rubygems" do
    rubygems = File.expand_path("../../../tmp/rubygems", __FILE__)
    manager = Bundler::SSLCerts::CertificateManager.new(rubygems)
    expect(manager).to be_up_to_date
  end

  hosts = %w(
    d2chzxaqi4y7f8.cloudfront.net
    rubygems.org
    s3.amazonaws.com
    staging.rubygems.org
  )

  hosts.each do |host|
    it "can securely connect to #{host}", :realworld do
      Bundler::SSLCerts::CertificateManager.new.connect_to(host)
    end
  end
end
