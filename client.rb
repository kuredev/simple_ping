require "logger"
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
#   client.exec(dest_ip_addr: "192.168.1.101") # => true or false
module SimplePing
  class Client
    # Wait time for ICMP Reply
    TIMEOUT_TIME = 10

    # constructor
    #
    # @param src_ip_addr [String] IP address of the interface to send ping,  ex: "192.168.1.100"
    def initialize(src_ip_addr:, log_level: Logger::INFO)
      @src_ip_addr = src_ip_addr
      @log_level = log_level
    end

    # Execute ping(ICMP).
    # Basically, it returns Boolean depending on the result.
    # Exception may be thrown due to unexpected error etc.
    #
    # @param dest_ip_addr [String] IP address of destination to send ping, ex: "192.168.1.101"
    # @param data         [String] ICMP Datagram, ex: "abc"
    # @return             [Boolean]
    def exec(dest_ip_addr:, data: nil)
      # Transmission
      icmp = ICMP.new(type: ICMP::TYPE_ICMP_ECHO_REQUEST, data: data)
      sockaddr = Socket.sockaddr_in(nil, dest_ip_addr)
      trans_data = icmp.to_trans_data
      socket.send(trans_data, 0, sockaddr)

      # Receive
      begin
        Timeout.timeout(TIMEOUT_TIME) do
          loop do
            mesg, _ = socket.recvfrom(1500)
            icmp_reply = RecvMessage.new(mesg).to_icmp

            if icmp.successful_reply?(icmp_reply)
              return true
            elsif icmp_reply.is_type_destination_unreachable?
              logger.warn { "Destination Unreachable!!" }
              return false
            elsif icmp_reply.is_type_redirect?
              logger.warn { "Redirect Required!!" }
              return false
            end
          end
        end
      rescue Timeout::Error => e
        logger.warn { "Timeout Occured! #{e}" }
        false
      end
    end

    private

    # @return [Logger]
    def logger
      @logger ||= begin
        logger = Logger.new(STDOUT)
        logger.level = @log_level
        logger
      end
    end

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
