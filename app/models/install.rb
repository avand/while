class Install < ActiveRecord::Base

  include IdentifierObfuscation

  belongs_to :user

end
