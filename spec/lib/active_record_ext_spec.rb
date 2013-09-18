require 'spec_helper'

describe WorthSaving::ActiveRecordExt do
  before do
    Rails.application.config.stub(:filter_parameters).and_return [:redacted_field]
  end

  with_model :WorthSavingDraft do
    table do |t|
      t.integer   :recordable_id
      t.string    :recordable_type
      t.integer   :scopeable_id
      t.string    :scopeable_type
      t.text      :form_data
    end

    model do
      belongs_to :recordable, polymorphic: true
      belongs_to :scopeable, polymorphic: true
    end
  end

  with_model :ImportantThing do
    table do |t|
      t.string :stuff
    end

    model do
      is_worth_saving
      if Rails.version.match /^3/
        attr_accessible :stuff
      end
    end
  end

  with_model :AnyThing do
  end

  before do
    if Rails.version.match /^3/
      class WorthSaving::Draft
        attr_accessible :recordable_id, :recordable_type, :scopeable_id, :scopeable_type, :form_data, :scopeable
      end
    end
  end

  describe 'subclass that is worth_saving' do
    describe 'associations' do
      let(:record) { ImportantThing.new }
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

    describe 'knowing it is worth_saving' do
      subject { ImportantThing.worth_saving? }

      it { should be_true }
    end

    describe 'instance knowing it is worth_saving' do
      subject { ImportantThing.new.worth_saving? }

      it { should eq true }
    end
  end

  describe 'normal(not-worth_saving) subclass' do
    describe 'knowing it is NOT worth_saving' do
      subject { AnyThing.worth_saving? }

      it { should eq false }
    end

    describe 'instance knowing it is NOT worth_saving' do
      subject { AnyThing.new.worth_saving? }

      it { should eq false }
    end
  end

  context 'worth_saving subclass with excepted fields' do
    with_model :ImportantThingButUnimportantAuthor do
      table do |t|
        t.string  :title
        t.string  :author
      end

      model do
        is_worth_saving except: :author
      end
    end

    context 'when field is NOT in the exceptions list' do
      describe 'knowing the field is worth_saving' do
        subject { ImportantThingButUnimportantAuthor.worth_saving? :title }

        it { should eq true }
      end

      describe 'having an instance that knows the field is worth_saving' do
        subject { ImportantThingButUnimportantAuthor.new.worth_saving? :title }

        it { should eq true }
      end
    end

    context 'when a field IS in the exceptions list' do
      describe 'knowing the field is NOT worth_saving' do
        subject { ImportantThingButUnimportantAuthor.worth_saving? :author }

        it { should eq false }
      end

      describe 'having an instance that knows the field is NOT worth_saving' do
        subject { ImportantThingButUnimportantAuthor.new.worth_saving? :author }

        it { should eq false }
      end
    end

    context 'when multiple fields are in the exceptions list (array argument)' do
      with_model :ImportantThingWithUnimportantFields do
        table do |t|
          t.string  :title
          t.string  :author
          t.string  :content
        end

        model do
          is_worth_saving except: [:author, :title]
        end
      end

      describe 'knowing which fields are and are NOT worth_saving' do
        it 'should be able to tell the difference' do
          ImportantThingWithUnimportantFields.worth_saving?(:author).should eq false
          ImportantThingWithUnimportantFields.worth_saving?(:title).should eq false
          ImportantThingWithUnimportantFields.worth_saving?(:content).should eq true
        end

        context 'Rails.application.filter_params' do
          it 'should not consider these fields worth_saving' do
            ImportantThingWithUnimportantFields.worth_saving?(:redacted_field).should eq false
          end
        end
      end
    end
  end

  describe 'scope option' do
    with_model :User do
    end

    with_model :ScopedThing do
      table do |t|
        t.belongs_to :user
      end

      model do
        if Rails.version.match /^3/
          attr_accessible :user
        end
        belongs_to :user
        is_worth_saving scope: :user
      end
    end

    describe '.worth_saving_scope' do
      it 'returns scope given in options' do
        ScopedThing.worth_saving_info.scope.should eq :user
      end
    end

    describe '.worth_saving_info.scope' do
      it 'returns scope given in options' do
        ScopedThing.worth_saving_info.scope.should eq :user
      end
    end

    describe '#worth_saving_draft' do
      let(:user) { User.create }
      let(:user2) { User.create }
      let(:thing) { ScopedThing.new user: user }

      context 'an unsaved ScopedThing' do
        it 'finds the draft by scope' do
          draft = WorthSaving::Draft.create recordable_type: 'ScopedThing', scopeable_id: user.id, scopeable_type: 'User'
          thing.worth_saving_draft.should eq draft
        end

        it 'does not find the draft belonging to the wrong scoped object' do
          draft = WorthSaving::Draft.create recordable_type: 'ScopedThing', scopeable_id: user.id, scopeable_type: 'User'
          thing = ScopedThing.new user: user2
          thing.worth_saving_draft.should be_nil
        end

        it 'does not find the draft belonging to the wrong recordable' do
          draft = WorthSaving::Draft.create recordable_type: 'ImportantThing', scopeable_id: user.id, scopeable_type: 'User'
          thing = ScopedThing.new user: user
          thing.worth_saving_draft.should be_nil
        end
      end

      context 'a saved Scopedthing' do
        it 'finds the draft through the has_one association' do
          thing.save
          draft = WorthSaving::Draft.create recordable_id: thing.id, recordable_type: 'ScopedThing'
          thing.reload
          thing.worth_saving_draft.should eq draft
        end
      end

      context "an unsaved unscoped thing" do
        subject { ImportantThing.new }
        let(:thing) { ImportantThing.new }
        let(:draft) { thing.build_worth_saving_draft }

        before do
          draft.save
        end

        its(:worth_saving_draft) { should eq draft }
      end
    end

    describe '#build_worth_saving_draft' do
      let(:user) { User.create }
      let(:thing) { ScopedThing.new user: user }

      context 'an unsaved ScopedThing' do
        subject { thing.build_worth_saving_draft }

        its(:recordable_type) { should eq 'ScopedThing' }
        its(:recordable_id) { should be_nil }
        its(:scopeable) { should eq user }

        describe 'disallowed attribute override' do
          subject { thing.build_worth_saving_draft recordable_type: 'WrongClass', scopeable_id: 4444 }

          its(:recordable_type) { should eq 'ScopedThing' }
          its(:scopeable) { should eq user }
        end
      end

      context 'an unsaved ScopedThing' do
        let(:thing) { ScopedThing.create user: user }
        subject { thing.build_worth_saving_draft form_data: 'some info' }

        its(:recordable) { should eq thing }
        its(:form_data) { should eq 'some info' }
      end
    end

    describe 'destruction of worth_saving_draft during save' do
      let(:thing) { ImportantThing.new stuff: 'Something' }

      context 'new record' do
        it 'happens after but not before' do
          draft = thing.create_worth_saving_draft
          WorthSaving::Draft.find(draft.id).should eq draft
          thing.save
          -> { WorthSaving::Draft.find(draft.id).should }.should raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'persisted record' do
        it 'happens after but not before' do
          thing.save
          draft = thing.create_worth_saving_draft
          WorthSaving::Draft.find(draft.id).should eq draft
          thing.update_attributes stuff: 'Changed something'
          -> { WorthSaving::Draft.find(draft.id).should }.should raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
