class ReoccuringEvent < ApplicationRecord
  has_one :task
  belongs_to :reoccuring_event_type
end
