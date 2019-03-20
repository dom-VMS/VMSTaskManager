module ApplicationHelper
    include Pagy::Frontend
    def flash_class(key)
        case key
            when 'notice' then return "info"
            when 'success' then return "success"
            when 'error' then return "danger"
            when 'alert' then return "warning"
        end
    end
end
