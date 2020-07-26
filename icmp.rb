module SimplePing
  class ICMP
    attr_reader :id, :seq_number

    # constructor
    #
    # @param code       [Integer] 0x01
    # @param type       [Integer] 0x01
    # @param id         [Integer] 0x01
    # @param seq_number [Integer] 0x01
    # @param data        [String] 0x01
    def initialize(code:, type:, id: nil, seq_number: nil, data: nil)
      @code = code
      @type = type
      @id = id || gen_id
      @seq_number = seq_number || gen_seq_number
      @data = data || gen_data
      @checksum = checksum
    end

    # Return the data format for sending with the Socket::send method
    #
    # @return [String]
    def to_trans_data
      bynary_data =
        @type.to_s(2).rjust(8, "0") +
        @code.to_s(2).rjust(8, "0") +
        @checksum.to_s(2).rjust(16, "0") +
        @id.to_s(2).rjust(16, "0") +
        @seq_number.to_s(2).rjust(16, "0")

      data_byte_arr = bynary_data.scan(/.{1,8}/)
      data_byte_arr.map! { |byte| byte.to_i(2).chr }
      data_byte_arr.join + @data
    end

    private

    # Calculate carry in 16bit
    # memo: https://qiita.com/kure/items/fa7e665c2259375d9a81
    #
    # @param num [String] ex: "11001100110100011"
    # @return [Integer]
    def carry_up(num)
      carry_up_num = num.length - 16
      original_value = num[carry_up_num, 16]
      carry_up_value = num[0, carry_up_num]
      sum = original_value.to_i(2) + carry_up_value&.to_i(2)
      sum ^ 0xffff
    end

    # return checksum value
    # Calculate 1's complement sum for each 16 bits
    # memo: https://qiita.com/kure/items/fa7e665c2259375d9a81
    #
    # @return [Integer]
    def checksum
      # Divide into 16 bits
      # ex: ["pi", "ng"]
      data_arr = @data.scan(/.{1,#{2}}/)
      # Calculate each ASCII code
      # ex: [28777, 28263]
      data_arr_int = data_arr.map do |data|
        (data.bytes[0] << 8) + (data.bytes[1].nil? ? 0 : data.bytes[1])
      end
      data_sum = data_arr_int.sum

      sum_with_16bit = (@type << 8 + @code) + @id + @seq_number + data_sum

      # calculate carry
      carry_up(sum_with_16bit.to_s(2).rjust(16, "0"))
    end

    # generate data
    #
    # TODO: random
    # @return [String]
    def gen_data
      "abcd"
    end

    # generate ID
    #
    # TODO: random
    # @return [Integer]
    def gen_id
      0x01
    end

    # generate sequence number
    #
    # TODO: random
    # @return [Integer]
    def gen_seq_number
      0x00af
    end
  end
end
