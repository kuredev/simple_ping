module SimplePing
  # Class that stores the received message
  # Implements a method to retrieve the ICMP header
  class RecvMessage
    def initialize(mesg)
      @mesg = mesg
    end

    # ID
    #
    # @return [Integer]
    def id
      (@mesg[24].bytes[0] << 8) + @mesg[25].bytes[0]
    end

    # Code
    #
    # @return [Integer]
    def code
      @mesg[21].bytes[0]
    end

    # Data
    #
    # @return [String]
    def data_value
      @mesg[28, @mesg.length.to_i - 28]
    end

    # sequence numebr
    #
    # @return [Integer]
    def seq_number
      (@mesg[26].bytes[0] << 8) + @mesg[27].bytes[0]
    end

    # Type
    #
    # @return [Integer]
    def type
      @mesg[20].bytes[0]
    end
  end
end
