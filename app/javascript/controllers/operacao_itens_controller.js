import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "rowTemplate", "codigoAddInput"]
  static values = { url: String }

  connect() {
    this.index = this.containerTarget.querySelectorAll("tr[data-item-row]").length
  }

  addByCodigo(e) {
    if (e) e.preventDefault()
    const input = this.codigoAddInputTarget
    const codigo = input.value?.trim()
    if (!codigo) return
    this.buscarEAdicionar(codigo)
  }

  async buscarEAdicionar(codigo) {
    const url = this.urlValue || "/produtos/buscar"
    try {
      const res = await fetch(`${url}?codigo=${encodeURIComponent(codigo)}`, { headers: { Accept: "application/json" } })
      const data = await res.json().catch(() => ({}))
      if (data.descricao != null) {
        const descricao = (data.descricao || "").trim()
        const existingRow = this.findRowByDescricao(descricao)
        if (existingRow) {
          const qtdInput = existingRow.querySelector("input[name*='[qtd]']")
          if (qtdInput) {
            const current = parseInt(qtdInput.value, 10) || 0
            qtdInput.value = String(current + 1)
          }
        } else {
          this.addRowComProduto(descricao)
        }
        this.codigoAddInputTarget.value = ""
        this.codigoAddInputTarget.focus()
        window.lucide.createIcons()
      } else {
        alert("Produto não encontrado.")
      }
    } catch (err) {
      alert("Produto não encontrado.")
    }
  }

  findRowByDescricao(descricao) {
    const normalized = descricao.trim()
    const rows = this.containerTarget.querySelectorAll("tr[data-item-row]")
    for (const row of rows) {
      if (row.classList.contains("hidden")) continue
      const descInput = row.querySelector("input[name*='[descricao]']")
      if (descInput && descInput.value.trim() === normalized) return row
    }
    return null
  }

  addRowComProduto(descricao) {
    const template = this.rowTemplateTarget
    const html = template.innerHTML.replace(/__INDEX__/g, this.index)
    this.containerTarget.insertAdjacentHTML("beforeend", html)
    const lastRow = this.containerTarget.querySelector("tr[data-item-row]:last-child")
    const descInput = lastRow.querySelector("input[name*='[descricao]']")
    const qtdInput = lastRow.querySelector("input[name*='[qtd]']")
    if (descInput) descInput.value = descricao
    if (qtdInput) qtdInput.value = "1"
    this.index++
  }

  removeRow(e) {
    const row = e.target.closest("tr[data-item-row]")
    if (!row) return
    const destroyInput = row.querySelector("input[name*='[_destroy]']")
    if (destroyInput) {
      destroyInput.value = "1"
      row.classList.add("hidden")
    } else {
      row.remove()
    }
  }
}