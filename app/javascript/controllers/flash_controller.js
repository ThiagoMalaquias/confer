import { Controller } from "@hotwired/stimulus" // ou "stimulus", dependendo do seu setup

export default class extends Controller {
  static targets = ["container"]
  static values = { timeout: Number }

  connect() {
    const ms = this.hasTimeoutValue ? this.timeoutValue : 5000 // 5s padrão
    if (ms > 0) {
      this.timeoutId = setTimeout(() => this.close(), ms)
    }
  }

  close() {
    const el = this.hasContainerTarget ? this.containerTarget : this.element

    el.classList.add("opacity-0", "-translate-y-2")

    setTimeout(() => {
      el.remove()
    }, 300)
  }

  disconnect() {
    if (this.timeoutId) clearTimeout(this.timeoutId)
  }
}