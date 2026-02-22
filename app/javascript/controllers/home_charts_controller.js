import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["config", "startDate", "endDate", "quickRange"]

  connect() {
    if (!this.hasConfigTarget || typeof window.Chart === "undefined") return
    const config = JSON.parse(this.configTarget.textContent)
    this.initializeCharts(config)
  }

  disconnect() {
    this.charts?.forEach(chart => chart?.destroy())
  }

  initializeCharts(config) {
    const Chart = window.Chart
    this.charts = []

    if (config.revenue && document.getElementById("revenueChart")) {
      this.charts.push(new Chart(document.getElementById("revenueChart"), {
        type: "line",
        data: {
          labels: config.revenue.labels,
          datasets: [{
            label: "Receita ($K)",
            data: config.revenue.data,
            borderColor: "#EF3F09",
            backgroundColor: "rgba(239, 63, 9, 0.1)",
            fill: true,
            tension: 0.4,
            pointBackgroundColor: "#EF3F09",
            pointBorderColor: "#fff",
            pointBorderWidth: 2
          }]
        },
        options: this.lineChartOptions("$", "K")
      }))
    }

    if (config.activity && document.getElementById("activityChart")) {
      this.charts.push(new Chart(document.getElementById("activityChart"), {
        type: "bar",
        data: {
          labels: config.activity.labels,
          datasets: [{
            label: "Usuários ativos",
            data: config.activity.data,
            backgroundColor: "#82D9D7",
            borderColor: "#5BCCCA",
            borderWidth: 1,
            borderRadius: 8
          }]
        },
        options: this.barChartOptions("K")
      }))
    }

    if (config.traffic && document.getElementById("trafficChart")) {
      this.charts.push(new Chart(document.getElementById("trafficChart"), {
        type: "pie",
        data: {
          labels: config.traffic.labels,
          datasets: [{
            data: config.traffic.data,
            backgroundColor: config.traffic.colors,
            borderWidth: 2,
            borderColor: "#fff"
          }]
        },
        options: this.pieChartOptions()
      }))
    }

    if (config.device && document.getElementById("deviceChart")) {
      this.charts.push(new Chart(document.getElementById("deviceChart"), {
        type: "doughnut",
        data: {
          labels: config.device.labels,
          datasets: [{
            data: config.device.data,
            backgroundColor: config.device.colors,
            borderWidth: 3,
            borderColor: "#fff"
          }]
        },
        options: { ...this.pieChartOptions(), cutout: "60%" }
      }))
    }
  }

  lineChartOptions(prefix = "", suffix = "") {
    return {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: "bottom", labels: { usePointStyle: true, padding: 20 } }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { callback: (v) => `${prefix}${v}${suffix}` },
          grid: { color: "rgba(0,0,0,0.1)" }
        },
        x: { grid: { display: false } }
      }
    }
  }

  barChartOptions(suffix = "") {
    return {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: "bottom", labels: { usePointStyle: true, padding: 20 } }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { callback: (v) => `${v}${suffix}` },
          grid: { color: "rgba(0,0,0,0.1)" }
        },
        x: { grid: { display: false } }
      }
    }
  }

  pieChartOptions() {
    return {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: "bottom",
          labels: { usePointStyle: true, padding: 15, font: { size: 12 } }
        }
      }
    }
  }

  applyQuickRange() {
    if (!this.hasQuickRangeTarget || !this.hasStartDateTarget || !this.hasEndDateTarget) return
    const quickRange = this.quickRangeTarget.value
    const endDate = new Date()
    const startDate = new Date()

    this.endDateTarget.value = endDate.toISOString().split("T")[0]

    switch (quickRange) {
      case "7d":
        startDate.setDate(endDate.getDate() - 7)
        break
      case "30d":
        startDate.setDate(endDate.getDate() - 30)
        break
      case "90d":
        startDate.setDate(endDate.getDate() - 90)
        break
      case "1y":
        startDate.setFullYear(endDate.getFullYear() - 1)
        break
      default:
        return
    }

    this.startDateTarget.value = startDate.toISOString().split("T")[0]
  }
}
