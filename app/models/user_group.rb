class UserGroup < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :tag_type_option, optional: true

end
