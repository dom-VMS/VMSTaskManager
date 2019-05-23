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

    def svg(name)
        image_tag "#{name}.svg", alt: "Varland Metal Service", size: '50'
    end

end
