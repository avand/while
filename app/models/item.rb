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

  scope :completed, -> { where "completed_at is not null" }
  scope :not_completed, -> { where completed_at: nil }
  scope :deleted, -> { where "deleted_at is not null" }
  scope :not_deleted, -> { where deleted_at: nil }
  scope :in_order, -> { order(:order, :created_at) }

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

  def hashid
    return nil if id.blank?
    salt = Rails.application.secrets[:hashids_salt]
    hashids = Hashids.new(salt)
    hashids.encode(id)
  end

  def to_param
    hashid
  end

  def self.find_by_hashid(hashid)
    raise ActiveRecord::RecordNotFound if hashid.blank?
    hashids = Hashids.new(Rails.application.secrets[:hashids_salt])
    find hashids.decode(hashid).first
  end

end
