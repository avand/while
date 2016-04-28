class Item < ApplicationRecord

  # https://color.hailpixel.com/#EBDAC2,E9E9BE,D0ECC6,C2DEEB,C8C6EC,E6B3E2
  COLORS = [
    ["apricot", "#EBDAC2"],
    ["banana", "#E9E9BE"],
    ["kiwi", "#D0ECC6"],
    ["blueberry", "#C2DEEB"],
    ["plum", "#C8C6EC"],
    ["rasberry", "#E6B3E2"]
  ]

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
