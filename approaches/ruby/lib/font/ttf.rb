require 'yaml'
require 'ft2'

module ResponsivePDF
  
  module Font

    class TTF

      def initialize(objects, font)
        @objects, @font = objects, font
        @descriptor = @objects.deref(@font[:FontDescriptor])
      end

      def data
        if @descriptor && @descriptor[:FontFile2]
          stream = @objects.deref(@descriptor[:FontFile2])
          stream.unfiltered_data
        else
          # FIXME should raise
          $stderr.puts "- TTF font not embedded"
          nil
        end
      end

      def content
        "#{@descriptor.to_yaml}"
      end

      def insepct
        "inspect not implemented"
      end

      # FIXME should not rely on ft2-ruby
      def face
        @face ||= FT2::Face.new_from_memory data, data.size
      end

      def save(filename)
        # puts "#{filename}"
        if @descriptor && @descriptor[:FontFile2]
          stream = @objects.deref(@descriptor[:FontFile2])
          File.open(filename, "wb") { |file| file.write stream.unfiltered_data }
        else
          $stderr.puts "- TTF font not embedded"
        end
      end
    end
  end
end