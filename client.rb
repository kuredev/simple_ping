require "socket"
require "timeout"
require_relative "recv_message"
require_relative "icmp"

# Simple Ping (ICMP) client
# Root privilege required to run
# ex)
#   require_relative "./simple_ping/client"
#
#   client = SimplePing::Client.new(src_ip_addr: "192.168.1.100")
#   client.exec(dest_ip_addr: "192.168.1.101")
module SimplePing
  class Client
    # ICMP header
    CODE_ICMP = 0x00
    TYPE_ICMP_ECHO_REPLY = 0x00
    TYPE_ICMP_ECHO_REQUEST = 0x08

    # Wait time for ICMP Reply
    TIMEOUT_TIME = 10

    # constructor
    #
    # @param src_ip_addr [String] IP address of the interface to send ping,  ex: "192.168.1.100"
    def initialize(src_ip_addr:)
      @src_ip_addr = src_ip_addr
    end

    # execute ping
    #
    # @param dest_ip_addr [String] IP address of destination to send ping, ex: "192.168.1.101"
    # @param data         [String] ICMP Datagram, ex: "abc"
    def exec(dest_ip_addr:, data: nil)
      # Transmission
      icmp = ICMP.new(code: CODE_ICMP, type: TYPE_ICMP_ECHO_REQUEST, data: data)
      sockaddr = Socket.sockaddr_in(nil, dest_ip_addr)
      trans_data = icmp.to_trans_data
      socket.send(trans_data, 0, sockaddr)

      # Receive
      begin
        Timeout.timeout(TIMEOUT_TIME) do
          loop do
            mesg_, _ = socket.recvfrom(1500)
            mesg = RecvMessage.new(mesg_)

            if icmp.id == mesg.id && mesg.type == TYPE_ICMP_ECHO_REPLY && icmp.seq_number == mesg.seq_number
              puts "SUCCESS!!"
              break
            end
          end
        end
      rescue Timeout::Error => e
        puts "Timeout Occur! #{e}"
      end
    end

    private

    # Socket instance
    #
    # @return [Socket]
    def socket
      @socket ||= begin
        socket = Socket.open(
          Socket::AF_INET,      # IPv4
          Socket::SOCK_RAW,     # RAW Socket
          Socket::IPPROTO_ICMP  # ICMP
        )
        socket.bind(Socket.sockaddr_in(nil, @src_ip_addr))
        socket
      end
    end
  end
end
