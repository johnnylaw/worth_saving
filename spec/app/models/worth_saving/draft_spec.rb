require 'spec_helper'

describe WorthSaving::Draft do
  before do
    class WorthSaving::Info; end
    class Record; end
  end

  subject { WorthSaving::Draft.table_name }

  it { should eq 'worth_saving_drafts' }

  describe 'associations' do
    describe ':recordable' do
      subject { WorthSaving::Draft.reflect_on_association :recordable }

      its(:macro) { should eq :belongs_to }
      its(:options) { should include :polymorphic }
    end

    describe ':scopeable' do
      subject { WorthSaving::Draft.reflect_on_association :scopeable }

      its(:macro) { should eq :belongs_to }
      its(:options) { should include :polymorphic }
    end
  end

  describe 'validations' do
    let(:record_class_worth_saving_info) { double Object }

    context 'unscoped recordable class' do
      context 'missing recordable_type' do
        let(:draft) { stub_model WorthSaving::Draft }

        it 'expects recordable_type' do
          draft.should_not be_valid
          draft.errors[:recordable_type].should eq ["can't be blank"]
        end
      end

      context 'valid draft' do
        before do
          WorthSaving::Info.should_receive(:class_with_name).with('Record').and_return Record
          record_class_worth_saving_info.should_receive(:scope).and_return nil
          Record.should_receive(:worth_saving_info).and_return record_class_worth_saving_info
        end

        subject { stub_model WorthSaving::Draft, recordable_type: 'Record' }
        it { should be_valid }
      end
    end

    context 'scoped recordable class' do
      subject { draft }
      let(:draft) { stub_model WorthSaving::Draft, recordable_type: 'Record' }

      before do
        WorthSaving::Info.should_receive(:class_with_name).with('Record').and_return Record
        record_class_worth_saving_info.stub(:scope).and_return :user
        Record.stub(:worth_saving_info).and_return record_class_worth_saving_info
      end

      context 'valid draft' do
        before do
          draft.stub(:scopeable).and_return double(Object)
        end

        it { should be_valid }
      end

      context 'missing scopeable' do
        before do
          draft.stub(:scopeable).and_return nil
          draft.valid?
        end

        it { should_not be_valid }
        its('errors.full_messages') { should eq ["Cannot save draft for new record without scopeable record.\nBe sure to build draft from Record with a non-nil user.\n"] }
      end
    end
  end # validation

  describe '#reconstituted_record' do
    subject { draft.reconstituted_record }
    let(:form_data) { 'record%5Bname%5D=John%20Smith&record%5Bage%5D=42' }
    let(:draft) { stub_model WorthSaving::Draft, recordable_id: 5, recordable_type: 'Record', form_data: form_data }
    let(:record) { double Record }

    context 'recordable_type is missing' do
      before do
        WorthSaving::Info.should_receive(:class_with_name).with('Record').and_return nil
      end

      it { should be_nil }
    end

    context 'recordable_type is present and name of a class' do
      before do
        WorthSaving::Info.should_receive(:class_with_name).with('Record').and_return Record
        Record.should_receive(:new).with('id' => 5, 'name' => 'John Smith', 'age' => '42').and_return record
      end

      it { should eq record }
    end
  end
end