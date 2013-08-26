require 'spec_helper'
require 'worth_saving'

describe ActiveRecord::Base do
  describe 'worth_saving subclass' do
    describe 'associations' do
      let(:record) { FactoryGirl.build :worth_saving_record }
      let(:draft) { record.build_worth_saving_draft }

      context 'when record is persisted' do
        it 'has a worth_saving draft' do
          record.save
          draft.save
          record.worth_saving_draft.should eq draft
        end
      end

      context 'when record is not persisted' do
        it 'has a worth_saving draft' do
          draft.save
          record.worth_saving_draft.should eq draft
        end
      end
    end

    describe 'ClassRegistry' do
      it 'adds class to registry when worth_saving is called' do
        class SomeClass < ActiveRecord::Base; end
        WorthSaving::ClassRegistry.should_receive(:add_entry).with SomeClass
        class SomeClass; worth_saving; end
      end
    end

    describe '.worth_saving_classes' do
    end

    describe 'knowing it is worth_saving' do
      subject { WorthSavingRecord.worth_saving? }

      it { should be_true }
    end

    describe 'instance knowing it is worth_saving' do
      subject { WorthSavingRecord.new.worth_saving? }

      it { should eq true }
    end
  end

  describe 'normal(not-worth_saving) subclass' do
    describe 'knowing it is NOT worth_saving' do
      subject { Record.worth_saving? }

      it { should eq false }
    end

    describe 'instance knowing it is NOT worth_saving' do
      subject { Record.new.worth_saving? }

      it { should eq false }
    end
  end

  context 'worth_saving subclass with excepted fields' do
    context 'when field is NOT in the exceptions list' do
      describe 'knowing the field is worth_saving' do
        subject { WorthSavingWithoutAuthorRecord.worth_saving? :title }

        it { should eq true }
      end

      describe 'having an instance that knows the field is worth_saving' do
        subject { WorthSavingWithoutAuthorRecord.new.worth_saving? :title }

        it { should eq true }
      end
    end

    context 'when a field IS in the exceptions list' do
      describe 'knowing the field is NOT worth_saving' do
        subject { WorthSavingWithoutAuthorRecord.worth_saving? :author }

        it { should eq false }
      end

      describe 'having an instance that knows the field is NOT worth_saving' do
        subject { WorthSavingWithoutAuthorRecord.new.worth_saving? :author }

        it { should eq false }
      end
    end

    context 'when multiple fields are in the exceptions list (array argument)' do
      before :all do
        class SomewhatWorthSavingRecord < ActiveRecord::Base
          self.table_name = 'records'
          worth_saving except: [:author, :title]
        end
      end

      describe 'knowing which fields are and are NOT worth_saving' do
        it 'should be able to tell the difference' do
          SomewhatWorthSavingRecord.worth_saving?(:author).should eq false
          SomewhatWorthSavingRecord.worth_saving?(:title).should eq false
          SomewhatWorthSavingRecord.worth_saving?(:content).should eq true
        end
      end
    end
  end
end