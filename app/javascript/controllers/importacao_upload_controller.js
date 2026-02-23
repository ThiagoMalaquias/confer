import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { tipo: { type: String, default: "produto" } }
  static targets = ["form", "fileInput", "tipoInput"]

  connect() {
    if (this.hasTipoInputTarget) this.tipoInputTarget.value = this.tipoValue
  }

  open() {
    if (this.hasFileInputTarget) this.fileInputTarget.click()
  }

  submit() {
    if (this.hasFileInputTarget && this.fileInputTarget.files.length > 0 && this.hasFormTarget) {
      this.formTarget.submit()
    }
  }
}