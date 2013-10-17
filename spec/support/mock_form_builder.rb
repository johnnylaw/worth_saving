class MockFormBuilder
  [:text_field, :hidden_field, :text_area, :search_field,
  :telephone_field, :phone_field, :url_field, :email_field,
  :number_field, :range_field, :input, :color_field, :date_field,
  :datetime_field, :datetime_local_field, :month_field,
  :week_field, :time_field].each do |meth|
    class_eval <<-EOS
      def #{meth}(method, options = {})
        mock_field options
      end
    EOS
  end

  def radio_button(method, tag_value, options = {})
    mock_field options
  end

  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    mock_field options
  end

  def date_select(method, options = {}, html_options = {})
    %Q{<select #{mock_class_attribute(html_options[:class])} #{mock_data_attributes(html_options[:data])}></select>}
  end

  def select(method, choices, options = {}, html_options = {})
    %Q{<select #{mock_class_attribute(html_options[:class])} #{mock_data_attributes(html_options[:data])}></select>}
  end

  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
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