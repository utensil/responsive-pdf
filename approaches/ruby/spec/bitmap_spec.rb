require 'spec_helper'

describe Util::BMP::Writer do

  before do
    @bmp = Util::BMP::Writer.new(4, 3)
  end

  [:save_as, :to_binary, :to_embed_img_tag].each do |method|
    it "should respond to #{method}" do
      @bmp.should respond_to(method)
    end
  end

  it 'should have more specs' do
    pending
  end

end