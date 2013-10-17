class MockFormBuilder
  [:text_field, :hidden_field, :text_area, :search_field,
  :telephone_field, :phone_field, :url_field, :email_field,
  :number_field, :range_field].each do |meth|
    class_eval <<-EOS
      def #{meth}(method, options = {})
        mock_field options
      end
    EOS
  end

  def select(method, choices, options = {}, html_options = {})
    %Q{<select #{mock_class_attribute(html_options[:class])} #{mock_data_attributes(html_options[:data])}></select>}
  end

  private

  def mock_field(options)
    %Q{<input #{mock_class_attribute(options[:class])} #{mock_data_attributes(options[:data])} />}
  end

  def mock_data_attributes(data)
    data ||= {}
    data.map{ |k, v| %Q{data-#{k.to_s.gsub('_', '-')}="#{v}"} }.join(' ')
  end

  def mock_class_attribute(css_class)
    %Q{class="#{css_class}"}
  end
end