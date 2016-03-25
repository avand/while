class Item < ApplicationRecord

  has_ancestry

  scope :completed, -> { where completed: true }

  belongs_to :user

  after_save :complete_parent

private

  def complete_parent
    if parent.present?
      parent.update completed: parent.descendants.all?(&:completed?)
    end
  end

end
