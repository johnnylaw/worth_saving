require 'spec_helper'
require 'support/mock_form_builder'

class SomeWorthSavingFormBuilder < MockFormBuilder
  include WorthSaving::FormBuilderMethods
end

describe WorthSaving::FormBuilderMethods do
  let(:form_model_object) { double }
  let(:form) { SomeWorthSavingFormBuilder.new }

  before do
    MockFormBuilder.any_instance.stub(:object).and_return form_model_object
  end

  context "when a form object has a method that is worth_saving (i.e. a Page has #content that is worth_saving)" do
    before do
      form_model_object.should_receive(:worth_saving?).with(:content).and_return true
    end

    [:text_field, :hidden_field, :text_area, :search_field,
    :telephone_field, :phone_field, :url_field, :email_field,
    :number_field, :range_field, :color_field, :date_field,
    :datetime_field, :datetime_local_field, :month_field,
    :week_field, :time_field].each do |helper|
      describe "##{helper}" do
        subject { form.send helper, :content, class: 'some class' }
        it { should eq '<input class="some class" data-worth-saving="true" />' }
      end
    end

    describe '#radio_button' do
      subject { form.radio_button(:content, 'blue', class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#check_box' do
      subject { form.check_box(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#date_select' do
      subject { form.date_select(:content, {}, class: 'some class') }
      it { should eq '<select class="some class" data-worth-saving="true"></select>' }
    end

    describe '#select' do
      subject { form.select(:content, [], {}, class: 'some class') }
      it { should eq '<select class="some class" data-worth-saving="true"></select>' }
    end

    describe '#collection_select' do
      subject { form.collection_select(:content, [], :id, :name, {}, class: 'some class') }
      it { should eq '<select class="some class" data-worth-saving="true"></select>' }
    end

    describe '#collection_check_boxes' do
      subject { form.collection_check_boxes(:content, [], :id, :name, {}, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#collection_radio_buttons' do
      pending
    end

    describe '#datetime_select' do
      pending
    end

    describe '#grouped_collection_select' do
      pending
    end

    describe '#time_select' do
      pending
    end

    describe '#time_zone_select' do
      pending
    end

    describe 'Support for simple_form' do
      describe '#input' do
        subject { form.input(:content, class: 'some class') }
        it { should eq '<input class="some class" data-worth-saving="true" />' }
      end
    end

    context 'worth_saving option is fed as false' do
      describe '#telephone_field' do # not all field types need be tested
        subject { form.range_field(:content, class: 'some class', worth_saving: false) }
        it { should eq '<input class="some class"  />' }
      end

      describe '#select' do
        subject { form.select(:content, [], { worth_saving: false }, class: 'some class') }
        it { should eq '<select class="some class" ></select>' }
      end

      describe '#radio_button' do
        subject { form.radio_button(:content, 'blue', worth_saving: false, class: 'some class') }
        it { should eq '<input class="some class"  />' }
      end

      describe '#check_box' do
        subject { form.check_box(:content, worth_saving: false, class: 'some class') }
        it { should eq '<input class="some class"  />' }
      end

      describe '#date_select' do
        subject { form.date_select(:content, { worth_saving: false }, class: 'some class') }
        it { should eq '<select class="some class" ></select>' }
      end

      describe '#collection_select' do
        subject { form.collection_select(:content, [], :id, :name, { worth_saving: false }, class: 'some class') }
        it { should eq '<select class="some class" ></select>' }
      end

      describe '#collection_check_boxes' do
        subject { form.collection_check_boxes(:content, [], :id, :name, { worth_saving: false }, class: 'some class') }
        it { should eq '<input class="some class"  />' }
      end

      describe '#collection_radio_buttons' do
        pending
      end

      describe '#datetime_select' do
        pending
      end

      describe '#grouped_collection_select' do
        pending
      end

      describe '#time_select' do
        pending
      end

      describe '#time_zone_select' do
        pending
      end
    end
  end

  context "when a form object has a method that is worth_saving (i.e. a Page has #content that is worth_saving)" do
    before do
      form_model_object.should_receive(:worth_saving?).with(:content).and_return false
    end

    describe '#email_field' do # not all simple fields need to be tested for false case
      subject { form.email_field(:content, class: 'some class') }
      it { should eq '<input class="some class"  />' }
    end

    describe '#radio_button' do
      subject { form.radio_button(:content, 'blue', class: 'some class') }
      it { should eq '<input class="some class"  />' }
    end

    describe '#check_box' do
      subject { form.check_box(:content, class: 'some class') }
      it { should eq '<input class="some class"  />' }
    end

    describe '#date_select' do
      subject { form.date_select(:content, {}, class: 'some class') }
      it { should eq '<select class="some class" ></select>' }
    end

    describe '#collection_select' do
      subject { form.collection_select(:content, [], :id, :name, {}, class: 'some class') }
      it { should eq '<select class="some class" ></select>' }
    end

    describe '#collection_check_boxes' do
      subject { form.collection_check_boxes(:content, [], :id, :name, {}, class: 'some class') }
      it { should eq '<input class="some class"  />' }
    end

    # collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {}, &block)
    describe '#collection_radio_buttons' do
      pending
    end

    describe '#datetime_select' do
      pending
    end

    # grouped_collection_select(method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {})
    describe '#grouped_collection_select' do
      pending
    end

    describe '#time_select' do
      pending
    end

    # time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
    describe '#time_zone_select' do
      pending
    end
  end
end