# Class that stores the received message
# Implements a method to retrieve the ICMP header
class SimplePing::RecvMessage
  # Code
  #
  # @return [Integer]
  def code
    @mesg[21].bytes[0]
  end

  # ID
  #
  # @return [Integer]
  def id
    (@mesg[24].bytes[0] << 8) + @mesg[25].bytes[0]
  end

  # constructor
  #
  # @param [String] mesg
  def initialize(mesg)
    @mesg = mesg
  end

  # Data
  #
  # @return [String]
  def data
    @mesg[28, @mesg.length.to_i - 28]
  end

  # sequence numebr
  #
  # @return [Integer]
  def seq_number
    (@mesg[26].bytes[0] << 8) + @mesg[27].bytes[0]
  end

  # create icmp object
  #
  # @return [SimplePing::ICMP]
  def to_icmp
    icmp = SimplePing::ICMP.new(code: code, type: type)
    if icmp.is_type_echo?
      icmp.id = id
      icmp.seq_number = seq_number
      icmp.data = data
    end
    icmp
  end

  # Type
  #
  # @return [Integer]
  def type
    @mesg[20].bytes[0]
  end
end
