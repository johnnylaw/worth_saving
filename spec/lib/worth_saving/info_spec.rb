require 'spec_helper'

describe WorthSaving::Info do
  describe '.attribute_whitelisting_required?' do
    subject { WorthSaving::Info.attribute_whitelisting_required? }

    context 'when using Rails3' do
      before { Rails.should_receive(:version).and_return '3.x.x' }
      it { should eq true }
    end

    context 'when using Rails4 and including ProtectedAttribute gem' do
      before do
        stub_const 'ProtectedAttributes', Class
        Rails.should_receive(:version).and_return '4.x.x'
      end

      it { should eq true }
    end

    context 'when using Rails4 and not including ProtectedAttribute gem' do
      before do
        Rails.should_receive(:version).and_return '4.x.x'
      end

      it { should eq false }
    end
  end
end