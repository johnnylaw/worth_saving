require 'spec_helper'

describe ActionView::Base do
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

  with_model :WorthSavingRecord do
    table do |t|
      t.string    :title
      t.string    :author
    end

    model do
      worth_saving
    end
  end

  with_model :WorthSavingExceptTitleRecord do
    table do |t|
      t.string    :title
      t.string    :author
    end

    model do
      worth_saving except: :title
    end
  end

  with_model :Record do
  end

  let(:view) { ActionView::Base.new }

  before do
    WorthSaving.send :remove_const, :Draft if defined? WorthSaving::Draft
    class WorthSaving::Draft < WorthSavingDraft; end

    view.stub(:worth_saving_records_path).and_return('/worth_saving_records')
    view.stub(:records_path).and_return('/records')
    view.stub(:worth_saving_except_title_records_path).and_return('/worth_saving_except_title_records')
    view.stub(:protect_against_forgery?).and_return(false)
    view.stub(:polymorphic_path).and_return('/mama')
  end

  # Some missing specs: test for what happens if we feed in an options hash other than {}
  #   Currently a worth_saving record will always have data-draft="worth_saving_record" b/c of the options.merge!('data-draft' => worth_saving_record)
  #   Quite possbily, however, we would like for a developer to be able to override this in a given form for a given field
  #     by feeding in :draft => false
  describe "when using form_for on a model that is worth_saving" do
    let(:worth_saving_record) { WorthSavingRecord.new }

    describe "and the record is new" do
      #TODO: test that another field does work
      it "text_field should not include data-record_type, data-record_id, or data-record_field if field is in except" do
        view.form_for WorthSavingExceptTitleRecord.new do |f|
          el = Capybara::Node::Simple.new(f.text_field :title).find('input')
          el['data-record_type'].should be_nil
          el['data-record_id'].should be_nil
          el['data-record_field'].should be_nil
        end
      end

      it "text_field should include data-record_type and a data-record_id attributes (model name and blank respectively)" do
        view.form_for worth_saving_record do |f|
          el = Capybara::Node::Simple.new(f.text_field :title).find('input')
          el['data-record_type'].should == 'WorthSavingRecord'
          # TODO should check for empty empty string not blank
          el['data-record_id'].should be_blank
          el['data-record_field'].should == 'title'
        end
      end

      it "text_field should include data-record_type and a data-record_id attributes (model name and blank respectively)" do
        view.form_for worth_saving_record do |f|
          f.text_field(:title).should =~ / data-record_type="WorthSavingRecord" /
          f.text_field(:title).should =~ / data-record_id="" /
          f.text_field(:title).should =~ / data-record_field="title" /
        end
      end

      it "select should include a data-draft attribute with value equal to the name of the model" do
        view.form_for worth_saving_record do |f|
          el = Capybara::Node::Simple.new(f.select :title, [1, 2, 3]).find('select')
          el['data-record_type'].should == 'WorthSavingRecord'
          el['data-record_id'].should be_blank
          el['data-record_field'].should == 'title'
        end
      end

      it "check_box should include a data-draft attribute with value equal to the name of the model" do
        view.form_for worth_saving_record do |f|
          # TODO: Think about whether you in fact want the hidden 0-valued field to have the worth_saving
          #     attributes.  Right now it does not.  This may actually
          #     be the desired effect (would reproduce the form as the user had it).  The AJAX call would
          #     send the value for checkboxes only if they were checked then; otherwise it would not include
          #     the field at all.  This seems correct for checkboxes.
          el = Capybara::Node::Simple.new(f.check_box :title).find('input[value="1"]')
          el['data-record_type'].should == 'WorthSavingRecord'
          el['data-record_id'].should be_blank
          el['data-record_field'].should == 'title'
        end
      end

      it "text_area should include a data-draft attribute with value equal to the name of the model" do
        view.form_for worth_saving_record do |f|
          el = Capybara::Node::Simple.new(f.text_area :title).find('textarea')
          el['data-record_type'].should == 'WorthSavingRecord'
          el['data-record_id'].should be_blank
          el['data-record_field'].should == 'title'
        end
      end

      it "radio_button should include a data-draft attribute with value equal to the name of the model" do
        view.form_for worth_saving_record do |f|
          el = Capybara::Node::Simple.new(f.radio_button :title, 1).find('input')
          el['data-record_type'].should == 'WorthSavingRecord'
          el['data-record_id'].should be_blank
          el['data-record_field'].should == 'title'
        end
      end
    end

    describe "and the record is from the database" do
      before :each do
        worth_saving_record.save
      end

      it "text_field should include a data-draft attribute with value equal to the name of the model with its to_param" do
        view.form_for worth_saving_record do |f|
          el = Capybara::Node::Simple.new(f.radio_button :title, 1).find('input')
          el['data-record_type'].should == 'WorthSavingRecord'
          el['data-record_id'].should == worth_saving_record.id
          el['data-record_field'].should == 'title'
        end
      end

      it "select should include a data-draft attribute with value equal to the name of the model with its to_param" do
        view.form_for worth_saving_record do |f|
          f.select(:title, [1, 2, 3]).should =~ / data-record_type="WorthSavingRecord" /
          f.select(:title, [1, 2, 3]).should =~ / data-record_id="#{worth_saving_record.id}" /
          f.select(:title, [1, 2, 3]).should =~ / data-record_field="title" /
        end
      end

      it "check_box should include a data-draft attribute with value equal to the name of the model with its to_param" do
        view.form_for worth_saving_record do |f|
          f.check_box(:title).should =~ / data-record_type="WorthSavingRecord" /
          f.check_box(:title).should =~ / data-record_id="#{worth_saving_record.id}" /
          f.check_box(:title).should =~ / data-record_field="title" /
        end
      end

      it "text_area should include a data-draft attribute with value equal to the name of the model with its to_param" do
        view.form_for worth_saving_record do |f|
          f.text_area(:title).should =~ / data-record_type="WorthSavingRecord" /
          f.text_area(:title).should =~ / data-record_id="#{worth_saving_record.id}" /
          f.text_area(:title).should =~ / data-record_field="title" /
        end
      end

      it "radio_button should include a data-draft attribute with value equal to the name of the modelwith its to_param" do
        view.form_for worth_saving_record do |f|
          f.radio_button(:title, 1).should =~ / data-record_type="WorthSavingRecord" /
          f.radio_button(:title, 1).should =~ / data-record_id="#{worth_saving_record.id}" /
          f.radio_button(:title, 1).should =~ / data-record_field="title" /
        end
      end
    end  # describe "and the record is from the database"

    it "text_field should not include a data-draft attribute if it is fed :draft => false in the options hash" do
      view.form_for worth_saving_record do |f|
        f.text_field(:title, :draft => false).should_not =~ /data-record/
      end
    end

    it "select should not include a data-draft attribute if it is fed :draft => false in the options hash" do
      view.form_for worth_saving_record do |f|
        f.select(:title, [1, 2, 3], :draft => false).should_not =~ /data-record/
      end
    end

    it "check_box should not include a data-draft attribute if it is fed :draft => false in the options hash" do
      view.form_for worth_saving_record do |f|
        f.check_box(:title, :draft => false).should_not =~ /data-record/
      end
    end

    it "text_area should not include a data-draft attribute if it is fed :draft => false in the options hash" do
      view.form_for worth_saving_record do |f|
        f.text_area(:title, :draft => false).should_not =~ /data-record/
      end
    end

    it "radio_buton should not include a data-draft attribute if it is fed :draft => false in the options hash" do
      view.form_for worth_saving_record do |f|
        f.radio_button(:title, 1, :draft => false).should_not =~ /data-record/
      end
    end

  end

  describe "when creating a form for a record that is NOT worth_saving" do

    it "text_field should not include a data-draft attribute" do
      ActionView::Base.new.text_field('record', :title, {}).should_not =~ /data-record_type/
      ActionView::Base.new.text_field('record', :title, {}).should_not =~ /data-record_id/
    end

    it "select should not include a data-draft attribute" do
      ActionView::Base.new.select('record', :title, [1, 2, 3]).should_not =~ /data-record_type/
      ActionView::Base.new.select('record', :title, [1, 2, 3]).should_not =~ /data-record_id/
    end

    it "check_box should not include a data-draft attribute" do
      ActionView::Base.new.check_box('record', :title, {}).should_not =~ /data-record_type/
      ActionView::Base.new.check_box('record', :title, {}).should_not =~ /data-record_id/
    end

    it "text_area should not include a data-draft attribute" do
      ActionView::Base.new.text_area('record', :title, {}).should_not =~ /data-record_type/
      ActionView::Base.new.text_area('record', :title, {}).should_not =~ /data-record_id/
    end

    it "radio_button should not include a data-draft attribute" do
      ActionView::Base.new.radio_button('record', :title, 1, {}).should_not =~ /data-record_type/
      ActionView::Base.new.radio_button('record', :title, 1, {}).should_not =~ /data-record_id/
    end

  end

end