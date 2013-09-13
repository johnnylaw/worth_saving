require 'spec_helper'

describe WorthSaving::Draft do
  with_model :Record do
    table do |t|
      t.string    :name
      t.integer   :age
    end

    model do
      if Rails.version.match /^3/
        attr_accessible :name, :age
      end
    end
  end

  before do
    class WorthSaving::Info; end
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

  describe 'attr_accessible' do
    subject { WorthSaving::Draft.attr_accessible[:default].to_a.reject(&:empty?) }

    context 'whitelisting attributes is not required' do
      before do
        WorthSaving.send :remove_const, :Draft
        WorthSaving::Info.should_receive(:attribute_whitelisting_required?).and_return false
        load WorthSaving::Engine.root + 'app/models/worth_saving/draft.rb'
      end

      it { should be_empty }
    end

    context 'whitelisting attributes is required' do
      before do
        WorthSaving.send :remove_const, :Draft
        WorthSaving::Info.should_receive(:attribute_whitelisting_required?).and_return true
        load WorthSaving::Engine.root + 'app/models/worth_saving/draft.rb'
      end

      it { should include 'scopeable' }
      it { should include 'recordable_id' }
      it { should include 'recordable_type' }
      it { should include 'scopeable_id' }
      it { should include 'scopeable_type' }
      it { should include 'form_data' }
    end
  end

  describe '#reconstituted_record' do
    subject { draft.reconstituted_record }

    context 'recordable_type is missing' do
      let(:draft) { stub_model WorthSaving::Draft, recordable_type: 'Record' }

      before do
        WorthSaving::Info.should_receive(:class_with_name).with('Record').and_return nil
      end

      it { should be_nil }
    end

    context 'recordable_type is present and name of a class' do
      let(:draft) { stub_model WorthSaving::Draft, recordable_id: record.id, recordable_type: 'Record', form_data: form_data }
      let(:record) { Record.create name: 'John Smith', age: nil }
      let(:form_data) { 'record%5Bname%5D=John%20N%20Smith&record%5Bage%5D=42' }

      before do
        WorthSaving::Info.should_receive(:class_with_name).with('Record').and_return Record
      end

      its(:id) { should eq record.id }
      its(:name) { should eq 'John N Smith' }
      its(:age) { should eq 42 }
    end
  end

  after :all do
    load WorthSaving::Engine.root + 'app/models/worth_saving/draft.rb'
  end
end