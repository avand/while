class Item < ApplicationRecord

  has_ancestry

  scope :completed, -> { where completed: true }
  scope :cleared, -> { where cleared: true }
  scope :not_cleared, -> { where cleared: [nil, false] }

  belongs_to :user

  before_create :make_last

  def make_last
    self.order = (siblings.maximum(:order) || -1) + 1
  end

end
