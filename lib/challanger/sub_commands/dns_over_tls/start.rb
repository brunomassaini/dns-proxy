require 'socket'
require 'openssl'
require 'sane'

module Challanger
  module DnsOverTls
    module Start
      def self.included(thor_class)
        thor_class.class_eval do

          desc "start", "Start DNS over TLS"
          long_desc <<-LONGDESC
            Write long description
          LONGDESC

          option :local_addr, type: :string, aliases: "-la", required: true
          option :local_port, type: :numeric, aliases: "-lp", required: true
          option :remote_addr, type: :string, aliases: "-ra", required: true
          option :remote_port, type: :numeric, aliases: "-rp", required: true
          def start
            local_addr = options[:local_addr]
            local_port = options[:local_port]
            @remote_addr = options[:remote_addr]
            @remote_port = options[:remote_port]

            log("starting dns server on #{local_addr}:#{local_port}")
            @server = TCPServer.open local_addr, local_port
            log('server up and listening')

            log("establishing ssl socket connection to #{@remote_addr}:#{@remote_port}")
            name_server = TCPSocket.new @remote_addr, @remote_port
            ssl_context = OpenSSL::SSL::SSLContext.new
            ssl_context.ssl_version = :SSLv23
            ssl_context.cert = OpenSSL::X509::Certificate.new(get_certificate)
            @ssl_socket = OpenSSL::SSL::SSLSocket.new(name_server, ssl_context)
            @ssl_socket.connect
            log('connected to name_server')
            
            puts ''

            loop do
              log('proxying query over tls :)')

              Thread.new(@server.accept) do |client|
                proxy_request(client)
                client.close
              end
            end
          end

          no_commands do
            def log(message)
              puts "#{Time.now}: #{message}"
            end

            def get_certificate
              # Try to connect to get certificate
              log('getting certificate from peer')
              
              ctx = OpenSSL::SSL::SSLContext.new
              sock = TCPSocket.new(@remote_addr, @remote_port)
              ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx) 
              ssl.connect            
              ssl.peer_cert
            end

            def proxy_request(client)
              
              loop do
                sockets = IO.select([client, @ssl_socket], nil, nil)
                
                if sockets[0].contain? client
                  sockets = IO.select(nil, [@ssl_socket], nil, 0)
                  query = client.recv 1024
                  
                  sleep 0.1
                  @ssl_socket.write query
                end

                if sockets[0].contain? @ssl_socket
                  sockets = IO.select(nil, [client], nil, 0)
                  response = @ssl_socket.sysread(1024)

                  sleep 0.1
                  client.write response
                end

              end
            end
          end
        end
      end
    end
  end
end
