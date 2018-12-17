class ReoccuringEvent < ApplicationRecord
  belongs_to :task
  belongs_to :reoccuring_event_type
end
