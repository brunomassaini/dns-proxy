require 'challanger/sub_commands/dns_over_tls/start'

module Challanger
  module DnsOverTls
    class DnsOverTls < Thor
      include Challanger::DnsOverTls::Start
    end
  end
end
