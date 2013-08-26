require 'spec_helper'
require 'worth_saving'

describe WorthSaving::ClassRegistry do
  describe '.add_entry' do
    it 'raises an exception if called with an object that is not a class' do
      -> { WorthSaving::ClassRegistry.add_entry 5 }.should raise_error 'Only worth_saving classes may be added'
    end

    it 'raises an exception if called with an object that is not worth_saving' do
      class DisallowedRecord; end
      DisallowedRecord.stub(:worth_saving?).and_return false
      -> { WorthSaving::ClassRegistry.add_entry DisallowedRecord }.should raise_error 'Only worth_saving classes may be added'
    end
  end

  context 'an added entry' do
    before do
      class AllowedRecord; end
      AllowedRecord.stub(:worth_saving?).and_return true
      WorthSaving::ClassRegistry.add_entry AllowedRecord
    end

    describe '.class_entry' do
      it 'finds it with a camelcase argument' do
        WorthSaving::ClassRegistry.class_entry('AllowedRecord').should eq AllowedRecord
      end

      it 'finds it with an underscore case argument' do
        WorthSaving::ClassRegistry.class_entry('allowed_record').should eq AllowedRecord
      end

      it 'finds it with an underscore symbol argument' do
        WorthSaving::ClassRegistry.class_entry(:allowed_record).should eq AllowedRecord
      end

      it 'returns nil if the class searched for has not been added' do
        WorthSaving::ClassRegistry.class_entry(:miscellaneous_record).should be_nil
      end
    end
  end
end