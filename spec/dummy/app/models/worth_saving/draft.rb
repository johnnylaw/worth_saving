class WorthSaving::Draft < ActiveRecord::Base
  self.table_name = 'worth_saving_drafts'
  belongs_to :recordable, polymorphic: true
  belongs_to :scopeable, polymorphic: true

  validates :recordable_type, presence: true
  validate :uniquely_findable, if: ->{ recordable_type && scoped_record? }

  private

  def scope_name
    return unless klass = ActiveRecord::Base.worth_saving_class_with_name(recordable_type)
    klass.worth_saving_scope.to_s
  end

  def uniquely_findable
    unless recordable || scopeable
      errors.add :base, <<-EOS
Cannot save draft for new record without scopeable record.
Be sure to call WorthSavingDraft.new(#{scope_name}: <some #{scope_name.camelcase}>)
      EOS
    end
  end

  def scoped_record?
    recordable_class = self.class.worth_saving_class_with_name recordable_type
    recordable_class.worth_saving_scope.present?
  end
end
