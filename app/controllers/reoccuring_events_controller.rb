class ReoccuringEventsController < ApplicationController
    def index
        @reoccuring_events = ReoccuringEvent.all
    end
end