require 'font/ttf'
require 'font/type1'

module ResponsivePDF

  module Font

    class Extractor

      def page(page)
        count = 0

        return count if page.fonts.nil? || page.fonts.empty?

        page.fonts.each do |label, font|
          next if complete_refs[font]

          process_font(page, font)

          complete_refs[font] = true
          count += 1
        end

        count
      end

      private

      # http://alt-soft.com/support/knowledge-base/variety-of-modern-font-formats/index.htm
      # FIXME should not just save the font
      def process_font(page, font)
        font = page.objects.deref(font)

        case font[:Subtype]
        when :Type0 then
          font[:DescendantFonts].each { |f| process_font(page, f) }
        when :Type1 then        
          Font::Type1.new(page.objects, font).save("#{font[:BaseFont]}.pfb")
        when :TrueType, :CIDFontType2 then
          Font::TTF.new(page.objects, font).save("#{font[:BaseFont]}.ttf")
        else
          $stderr.puts "unsupported font type #{font[:Subtype]}"
        end
      end

      def complete_refs
        @complete_refs ||= {}
      end

    end
  end
end