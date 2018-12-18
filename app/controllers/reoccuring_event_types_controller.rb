class ReoccuringEventTypesController < ApplicationController
    def index
        @reoccuring_event_types = ReoccuringEventType.all
        puts @reoccuring_event_types.to_json
    end

    def show
    end
end
