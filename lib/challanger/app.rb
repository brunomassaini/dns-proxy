module Challanger
  class App < Thor

    desc "dns_over_tls COMMAND", "DNS over TLS"
    subcommand('dns_over_tls', Challanger::DnsOverTls::DnsOverTls)

  end
end
