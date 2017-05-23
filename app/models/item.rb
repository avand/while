class Item < ApplicationRecord

  include IdentifierObfuscation

  COLORS = [
    ["banana", "#FCD127"],
    ["clementine", "#FFA921"],
    ["cherry", "#E85155"],
    ["grape", "#C239C4"],
    ["blueberry", "#19AAE3"]
  ]

  has_ancestry

  scope :completed, -> { where "completed_at is not null" }
  scope :not_completed, -> { where completed_at: nil }
  scope :deleted, -> { where "deleted_at is not null" }
  scope :not_deleted, -> { where deleted_at: nil }

  belongs_to :user

  before_create :make_last

  def completed?
    completed_at.present?
  end

  def deleted?
    deleted_at.present?
  end

  def make_last
    self.order = (siblings.maximum(:order) || -1) + 1
  end

  def soft_delete(time)
    update deleted_at: time
    descendants.not_deleted.update deleted_at: time
  end

end
