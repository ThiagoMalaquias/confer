import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (typeof window.lucide !== "undefined" && window.lucide.createIcons) {
      window.lucide.createIcons()
    }
  }
}
