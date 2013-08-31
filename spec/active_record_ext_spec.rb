require 'spec_helper'
require 'worth_saving'

describe WorthSaving::ActiveRecordExt do
  with_model :WorthSavingDraft do
    table do |t|
      t.integer   :recordable_id
      t.string    :recordable_type
      t.integer   :scopeable_id
      t.string    :scopeable_type
      t.text      :info
    end

    model do
      belongs_to :recordable, polymorphic: true
      belongs_to :scopeable, polymorphic: true
    end
  end

  with_model :ImportantThing do
    model do
      worth_saving
    end
  end

  with_model :AnyThing do
  end

  before do
    WorthSaving.send :remove_const, :Draft if defined? WorthSaving::Draft
    class WorthSaving::Draft < WorthSavingDraft; end
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

    describe '.worth_saving_classes' do
      it 'adds class to registry when worth_saving is called' do
        ActiveRecord::Base.worth_saving_classes.should include ImportantThing
      end

      it 'does not add classes that are not designated as worth_saving' do
        ActiveRecord::Base.worth_saving_classes.should_not include AnyThing
      end
    end

    describe '.worth_saving_class_with_name(name)' do
      let(:classes)  { [Hash, Array] }

      context 'argument given is a string representation of a worth_saving class' do
        it 'returns the class' do
          ActiveRecord::Base.stub(:_worth_saving_classes).and_return classes
          ActiveRecord::Base.worth_saving_class_with_name('hash').should eq Hash
        end
      end

      context 'argument given is a string representation of a class that is not worth_saving' do
        it 'returns the class' do
          ActiveRecord::Base.stub(:_worth_saving_classes).and_return classes
          ActiveRecord::Base.worth_saving_class_with_name('object').should be_nil
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
        worth_saving except: :author
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
          worth_saving except: [:author, :title]
        end
      end

      describe 'knowing which fields are and are NOT worth_saving' do
        it 'should be able to tell the difference' do
          ImportantThingWithUnimportantFields.worth_saving?(:author).should eq false
          ImportantThingWithUnimportantFields.worth_saving?(:title).should eq false
          ImportantThingWithUnimportantFields.worth_saving?(:content).should eq true
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
        belongs_to :user
        worth_saving scope: :user
      end
    end

    describe '.worth_saving_scope' do
      it 'returns scope given in options' do
        ScopedThing.worth_saving_scope.should eq :user
      end
    end

    describe '.worth_saving_scope_class' do
      it 'returns scope given in options' do
        ScopedThing.worth_saving_scope_class.should eq User
      end

      it 'raises an error if scope is not an ActiveRecord::Base subclass' do
        -> { class ScopedThing
               worth_saving scope: :object
             end
        }.should raise_error 'Scope must be ActiveRecord::Base subclass'
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
          draft = WorthSaving::Draft.create recordable_type: 'OtherTypeOfThing', scopeable_id: user.id, scopeable_type: 'User'
          thing = ScopedThing.new user: user
          thing.worth_saving_draft.should be_nil
        end
      end

      context 'a saved Scopedthing' do
        it 'finds the draft through the has_one association' do
          thing.save
          draft = WorthSaving::Draft.create recordable_id: thing.id, recordable_type: 'ScopedThing'
          thing.worth_saving_draft.should eq draft
        end
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
        subject { thing.build_worth_saving_draft info: 'some info' }

        its(:recordable) { should eq thing }
        its(:info) { should eq 'some info' }
      end
    end
  end
end