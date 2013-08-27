require 'spec_helper'
require 'worth_saving'

# 'records' table defined in spec/dummy/db/migrate/20130823064546_create_records.rb

describe ActiveRecord::Base do
  describe 'worth_saving subclass' do
    before :all do
      class WorthSavingRecord < ActiveRecord::Base
        self.table_name = 'records'
        worth_saving
      end
    end

    describe 'associations' do
      subject { WorthSavingRecord.reflect_on_all_associations }

      its(:size) { should eq 1 }
      its('first.name') { should eq :worth_saving_draft }
      its('first.macro') { should eq :has_one }
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
    before :all do
      class Record < ActiveRecord::Base; end
    end

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
    before :all do
      class MostlyWorthSavingRecord < ActiveRecord::Base
        self.table_name = 'records'
        worth_saving except: :author
      end
    end

    context 'when field is NOT in the exceptions list' do
      describe 'knowing the field is worth_saving' do
        subject { MostlyWorthSavingRecord.worth_saving? :title }

        it { should eq true }
      end

      describe 'having an instance that knows the field is worth_saving' do
        subject { MostlyWorthSavingRecord.new.worth_saving? :title }

        it { should eq true }
      end
    end

    context 'when a field IS in the exceptions list' do
      describe 'knowing the field is NOT worth_saving' do
        subject { MostlyWorthSavingRecord.worth_saving? :author }

        it { should eq false }
      end

      describe 'having an instance that knows the field is NOT worth_saving' do
        subject { MostlyWorthSavingRecord.new.worth_saving? :author }

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