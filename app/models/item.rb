class Item < ApplicationRecord

  include IdentifierObfuscation

  COLORS = [
    "#FCD127", # banana
    "#FFA921", # clementine
    "#E85155", # cherry
    "#C239C4", # grape
    "#19AAE3"  # blueberry
  ]

  has_ancestry

  scope :completed, -> { where "completed_at is not null" }
  scope :not_completed, -> { where completed_at: nil }
  scope :deleted, -> { where "deleted_at is not null" }
  scope :not_deleted, -> { where deleted_at: nil }

  belongs_to :user

  before_create :make_last
  before_create :assign_color, if: :root?

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

  def assign_color
    index = 0

    if user.present?
      last_colored_item = user.items.roots.where(color: COLORS).last

      if last_colored_item.present?
        index = COLORS.index(last_colored_item.color) + 1
        index = 0 unless index < COLORS.size
      end
    end

    self.color = COLORS[index]
  end

end
