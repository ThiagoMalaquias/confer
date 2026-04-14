class HomeController < ApplicationController
  def index
    @operacoes = Operacao.count
    @pedidos_baixados = Operacao.where(status: "CONCLUIDO")
    @count_pedidos_baixados = @pedidos_baixados.count
    @count_pedidos_a_baixar = Operacao.where(status: "PENDENTE").count
    @count_cestas_a_montar = @pedidos_baixados.sum(:qtd)

      # Dados para o gráfico de receita (linha)
    @revenue_labels = %w[Jan Fev Mar Abr Mai Jun]
    @revenue_data = [42, 55, 48, 67, 58, 72]

    # Dados para o gráfico de atividade (barras)
    @activity_labels = %w[Seg Ter Qua Qui Sex Sáb Dom]
    @activity_data = [28, 34, 45, 52, 48, 35, 29]

    # Dados para o gráfico de fontes de tráfego (pizza)
    @traffic_labels = ['Busca orgânica', 'Direto', 'Redes sociais', 'E-mail', 'Referência']
    @traffic_data = [35, 25, 20, 12, 8]
    @traffic_colors = ['#EF3F09', '#82D9D7', '#FAAC7B', '#C5E151', '#A855F7']

    # Dados para o gráfico de dispositivos (rosquinha)
    @device_labels = %w[Desktop Mobile Tablet]
    @device_data = [45, 40, 15]
    @device_colors = ['#C5E151', '#82D9D7', '#FAAC7B']

    # Config única para o Stimulus (home_charts_controller)
    @charts_config = {
      revenue:  { labels: @revenue_labels,  data: @revenue_data },
      activity: { labels: @activity_labels, data: @activity_data },
      traffic:  { labels: @traffic_labels,  data: @traffic_data,  colors: @traffic_colors },
      device:   { labels: @device_labels,   data: @device_data,   colors: @device_colors }
    }
  end
end
