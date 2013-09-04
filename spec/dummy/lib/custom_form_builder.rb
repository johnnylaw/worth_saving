class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(field_name, options = {})
    options[:data] ||= {}
    options[:data].reverse_merge! thingy: 'YourMom'
    super
  end
end