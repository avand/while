module IdentifierObfuscation

  extend ActiveSupport::Concern

  def hashid
    return nil if id.blank?
    salt = Rails.application.secrets[:hashids_salt]
    hashids = Hashids.new(salt)
    hashids.encode(id)
  end

  def to_param
    hashid
  end

  class_methods do
    def find_by_hashid(hashid)
      raise ActiveRecord::RecordNotFound if hashid.blank?
      hashids = Hashids.new(Rails.application.secrets[:hashids_salt])
      find hashids.decode(hashid).first
    end
  end

end
