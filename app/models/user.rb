class User < ApplicationRecord

   validates_presence_of :employee_number, :email
end
