import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["container", "rowTemplate", "eanInput", "loteInput", "vencimentoInput", "fabricacaoInput", "prazoInput"]

  connect() {
    this.index = this.containerTarget.querySelectorAll("tr[data-item-row]").length
  }

  blockEnterOnForm(event) {
    const isEnter =
      event.key === "Enter" ||
      event.code === "Enter" ||
      event.code === "NumpadEnter" ||
      event.keyCode === 13

    if (!isEnter) return
    if (event.target && event.target.tagName === "TEXTAREA") return

    event.preventDefault()
  }

  preventEnter(event) {
    event.preventDefault()
  }

  addByEan(event) {
    if (event) event.preventDefault()
    const ean = this.eanInputTarget.value?.trim()
    const lote = this.loteInputTarget.value?.trim()
    const vencimento = this.vencimentoInputTarget.value?.trim()
    const fabricacao = this.fabricacaoInputTarget.value?.trim()
    const prazo = this.prazoInputTarget.value?.trim()

    if (!ean || !lote || !vencimento) return
    if (fabricacao && !prazo) {
      alert("Prazo é obrigatório quando fabricacao é informado.")
      return
    }

    this.buscarEAdicionar(ean, lote, vencimento, fabricacao, prazo)
  }

  async buscarEAdicionar(ean, lote, vencimento, fabricacao, prazo) {
    const url = this.urlValue

    try {
      const res = await fetch(url, {
        headers: { Accept: "application/json", "Content-Type": "application/json" },
        method: "POST",
        body: JSON.stringify({ operacao_pedido: { ean, lote, vencimento, fabricacao, prazo } })
      })
      const data = await res.json().catch(() => ({}))

      if (data.codigo != null) {
        this.addRow(data)
        this.eanInputTarget.value = ""
        this.loteInputTarget.value = ""
        this.vencimentoInputTarget.value = ""
        this.fabricacaoInputTarget.value = ""
        this.prazoInputTarget.value = ""
        this.eanInputTarget.focus()
        if (window.lucide) window.lucide.createIcons()
      } else {
        alert(data.error)
        setTimeout(() => {
          window.location.reload()
        }, 1000)
      }
    } catch (_err) {
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
    const idInput = lastRow.querySelector("input[name*='[id]']") // novo
    const loteInput = lastRow.querySelector("input[name*='[lote]']")
    const vencimentoInput = lastRow.querySelector("input[name*='[vencimento]']")
    const fabricacaoInput = lastRow.querySelector("input[name*='[fabricacao]']")
    const prazoInput = lastRow.querySelector("input[name*='[prazo]']")
    const descricaoCell = lastRow.querySelector(".descricao-cell")

    if (codigoInput) codigoInput.value = produto.codigo || ""
    if (descricaoInput) descricaoInput.value = produto.descricao || ""
    if (idInput) idInput.value = produto.item_id || ""                 // novo
    if (produto.item_id) lastRow.dataset.itemId = String(produto.item_id) // novo

    if (loteInput) loteInput.value = this.loteInputTarget?.value ?? ""
    if (vencimentoInput) vencimentoInput.value = this.vencimentoInputTarget?.value ?? ""
    if (fabricacaoInput) fabricacaoInput.value = this.fabricacaoInputTarget?.value ?? ""
    if (prazoInput) prazoInput.value = this.prazoInputTarget?.value ?? ""
    if (descricaoCell) descricaoCell.textContent = produto.descricao ?? ""

    this.index++
  }

  async removeRow(event) {
    if (!confirm("Tem certeza que deseja remover este item do pedido?")) return

    const row = event.target.closest("tr[data-item-row]")
    if (!row) return

    const itemId =
      row.dataset.itemId ||
      row.querySelector("input[name*='[id]']")?.value

    if (itemId) {
      const csrf = document.querySelector("meta[name='csrf-token']")?.content

      const res = await fetch(`/operacao_pedido_itens/${itemId}`, {
        method: "DELETE",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": csrf
        }
      })

      if (res.status !== 204) {
        alert("Não foi possível remover o item.")
        return
      }

      row.remove()
      return
    }

    const destroyInput = row.querySelector("input[name*='[_destroy]']")
    if (destroyInput) {
      destroyInput.value = "1"
      row.classList.add("hidden")
    } else {
      row.remove()
    }
  }
}