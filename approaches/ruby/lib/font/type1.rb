require 'ft2'

module ResponsivePDF

  module Font

    class Type1
      def initialize(objects, font)
        @objects, @font = objects, font
        @descriptor = @objects.deref(@font[:FontDescriptor])
      end

      def data
        if @descriptor && @descriptor[:FontFile]
          @stream ||= @objects.deref(@descriptor[:FontFile])
          @data ||= @stream.unfiltered_data
        else
          $stderr.puts "Type1 - TTF font not embedded"
          nil
        end
      end

      # FIXME should save to a file handle instead of a file name
      def save(filename)
        File.open("#{filename}", "wb") { |file| file.write data }

        #File.open("#{filename}", "wb") { |file| file.write content }
      end

      def content
        if data
          begin_of_eexec = data.index('eexec') + 'eexec'.size
          while data[begin_of_eexec].match /[[:space:]]/
            #$stderr.puts "#{unfiltered_data[begin_of_eexec]} match"
            begin_of_eexec += 1
          end
          decrypted = decrypt_eexec(data[begin_of_eexec..-1])
          #decrypted = decrypt_each_charstring(decrypted) 
          decrypted
        else
          "?"
        end
      end

      def face
        @face ||= FT2::Face.new_from_memory(data, data.size)
      end

      def inspect
        "<Font family=#{face.family} flags=#{face.flags} italic?=#{face.italic?} \
        bold?=#{face.bold?} height=#{face.height}>"
      end

      def decrypt_eexec(cipher)
        r = 55665
        c1 = 52845
        c2 = 22719

        ret = StringIO.new
        ret.binmode

        cipher.bytes do |cipher_byte|
          plain_byte = (cipher_byte.to_i ^ (r>>8))
          r = ((cipher_byte.to_i + r) * c1 + c2) & ((1 << 16) - 1)
          ret.putc plain_byte
        end
        ret.flush
        ret.string[4..-1]
      end

      def decrypt_charstring(cipher)
        r = 4330
        c1 = 52845
        c2 = 22719

        ret = StringIO.new
        ret.binmode

        cipher.bytes do |cipher_byte|
          plain_byte = (cipher_byte.to_i ^ (r>>8))
          r = ((cipher_byte.to_i + r) * c1 + c2) & ((1 << 16) - 1)
          ret.putc plain_byte
        end
        ret.flush
        ret.string[4..-1]
      end

      #def decrypt_each_charstring(string)
      #  ret = StringIO.new

      #  remain = string
      #  
      #  while begin_of_charstring = remain.index(' RD ')

      #    ret.write remain[0..(begin_of_charstring - 1)]

      #    # find the length digits and to_i it
      #    begin_of_length = begin_of_charstring  
      #    while remain[begin_of_length - 1].match(/\d/)
      #      begin_of_length -= 1
      #    end
      #    length = remain[begin_of_length..(begin_of_charstring - 1)].to_i
      #    begin_of_charstring = begin_of_charstring + ' RD '.size

      #    remain = remain[begin_of_charstring..-1]
      #    data = remain.byteslice(0..(length - 1)) #+3 = ND or NP
      #    remain = remain.byteslice(length..-1)

      #    raise "#{data.bytesize} != #{length}" if data.bytesize != length
      #    raise "wrong end!" if !remain.start_with?(' NP') && !remain.start_with?(' ND')

      #    ret.write "<rd>\n#{decrypt_charstring(data)}\n</rd>\n"
      #     
      #    #$stderr.puts length, data


      #  end

      #  ret.string
      #end
    end
  end

end