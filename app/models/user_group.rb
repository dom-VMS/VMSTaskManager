class UserGroup < ApplicationRecord
    belongs_to :user
    belongs_to :tag_type_option
end
