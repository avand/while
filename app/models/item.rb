class Item < ApplicationRecord

  has_ancestry

  scope :completed, -> { where completed: true }
  scope :cleared, -> { where cleared: true }
  scope :not_cleared, -> { where cleared: [nil, false] }

  belongs_to :user

  after_save :complete_parent

private

  def complete_parent
    if parent.present?
      parent.update completed: parent.descendants.all?(&:completed?)
    end
  end

end
