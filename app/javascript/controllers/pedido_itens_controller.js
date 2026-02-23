import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "rowTemplate", "eanInput", "loteInput", "vencimentoInput", "fabricacaoInput", "prazoInput"]

  connect() {
    this.index = this.containerTarget.querySelectorAll("tr[data-item-row]").length
  }

  addByEan(e) {
    if (e) e.preventDefault()
    const ean = this.eanInputTarget.value?.trim()
    if (!ean) return
    this.buscarEAdicionar(ean)
  }

  async buscarEAdicionar(ean) {
    const url = this.urlValue || "/produtos/buscar_por_ean"
    try {
      const res = await fetch(`${url}?ean=${encodeURIComponent(ean)}`, { headers: { Accept: "application/json" } })
      const data = await res.json().catch(() => ({}))
      if (data.codigo != null) {
        this.addRow(data)
        this.eanInputTarget.value = ""
        this.eanInputTarget.focus()
        if (window.lucide) window.lucide.createIcons()
      } else {
        alert("Produto não encontrado.")
      }
    } catch (err) {
      alert("Produto não encontrado.")
    }
  }

  addRow(produto) {
    const template = this.rowTemplateTarget
    const html = template.innerHTML.replace(/__INDEX__/g, this.index)
    this.containerTarget.insertAdjacentHTML("beforeend", html)
    const lastRow = this.containerTarget.querySelector("tr[data-item-row]:last-child")
    const codigoInput = lastRow.querySelector("input[name*='[codigo]']")
    const descricaoInput = lastRow.querySelector("input[name*='[descricao]']")
    const loteInput = lastRow.querySelector("input[name*='[lote]']")
    const vencimentoInput = lastRow.querySelector("input[name*='[vencimento]']")
    const fabricacaoInput = lastRow.querySelector("input[name*='[fabricacao]']")
    const prazoInput = lastRow.querySelector("input[name*='[prazo]']")
    const eanCell = lastRow.querySelector(".ean-cell")
    if (codigoInput) codigoInput.value = produto.codigo || ""
    if (descricaoInput) descricaoInput.value = produto.descricao || ""
    if (loteInput) loteInput.value = this.loteInputTarget?.value ?? ""
    if (vencimentoInput) vencimentoInput.value = this.vencimentoInputTarget?.value ?? ""
    if (fabricacaoInput) fabricacaoInput.value = this.fabricacaoInputTarget?.value ?? ""
    if (prazoInput) prazoInput.value = this.prazoInputTarget?.value ?? ""
    if (eanCell) eanCell.textContent = produto.ean ?? ""
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