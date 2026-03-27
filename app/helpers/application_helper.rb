module ApplicationHelper
  def status_class(operacao)
    border_class =
     case operacao.status
     when "CONCLUIDO"
       "border-green-600"
     when "ERRO", "CANCELADO"
       "border-red-600"
     else
       "border-border"
     end 

    base_class = "flex items-center justify-center aspect-square min-h-[3.5rem] rounded-card border-2 bg-white text-foreground font-bold text-lg hover:bg-primary/5 transition-colors shadow-sm" 

    hover_border =
      case operacao.status
      when "CONCLUIDO"
        "hover:border-green-700"
      when "ERRO", "CANCELADO"
        "hover:border-red-700"
      else
        "hover:border-primary hover:text-primary"
      end

    classes = "#{base_class} #{border_class} #{hover_border}"

    classes
  end
end
