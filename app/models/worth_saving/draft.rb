class WorthSaving::Draft < ActiveRecord::Base
  self.table_name = 'worth_saving_drafts'
  belongs_to :recordable, polymorphic: true
  belongs_to :scopeable, polymorphic: true

  validates :recordable_type, presence: true
  validate :uniquely_findable, if: ->{ recordable_type && scoped_record? }

  def reconstituted_record
    recordable_class && recordable_class.new(recordable_params)
  end

  private

  def uniquely_findable
    unless recordable || scopeable
      errors.add :base, <<-EOS
Cannot save draft for new record without scopeable record.
Be sure to build draft from #{recordable_type} with a non-nil #{scope_name}.
      EOS
    end
  end

  def scope_name
    recordable_class && recordable_class.worth_saving_info.scope
  end

  def scoped_record?
    recordable_class.worth_saving_info.scope.present?
  end

  def recordable_class
    @recordable_class ||= WorthSaving::Info.class_with_name recordable_type
  end

  def recordable_params
    params = Rack::Utils.parse_nested_query(form_data)
    { 'id' => recordable_id }.merge params[recordable_type.underscore]
  end
end