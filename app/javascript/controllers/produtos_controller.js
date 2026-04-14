import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async gerarExcel(event) {
    event.preventDefault()

    try {
      const params = new URLSearchParams(window.location.search)
      const query = params.toString()
      const url = query ? `/produtos/gerar_excel?${query}` : "/produtos/gerar_excel"

      debugger

      const response = await fetch(url, {
        method: "GET",
        headers: { Accept: "application/json" }
      })

      if (!response.ok) {
        throw new Error("Falha ao gerar arquivo")
      }

      const data = await response.json()
      if (!data?.link) {
        throw new Error("Link não retornado")
      }

      window.open(data.link, "_blank")
    } catch (_error) {
      alert("Não foi possível gerar o Excel.")
    }
  }
}
