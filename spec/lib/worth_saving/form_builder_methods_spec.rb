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

    describe '#text_field' do
      subject { form.text_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#hidden_field' do
      subject { form.hidden_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#text_area' do
      subject { form.text_area(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#search_field' do
      subject { form.search_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#telephone_field' do
      subject { form.telephone_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#phone_field' do
      subject { form.phone_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#url_field' do
      subject { form.url_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#email_field' do
      subject { form.email_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#number_field' do
      subject { form.number_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#range_field' do
      subject { form.range_field(:content, class: 'some class') }
      it { should eq '<input class="some class" data-worth-saving="true" />' }
    end

    describe '#select' do
      subject { form.select(:content, [], {}, class: 'some class') }
      it { should eq '<select class="some class" data-worth-saving="true"></select>' }
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
  end
end