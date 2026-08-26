import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "item"]
  static values = { matchOn: String }

  filter() {
    const searchTerm = this.inputTarget.value.trim().toLowerCase()

    this.itemTargets.forEach(item => {
      const text = this.getItemText(item).toLowerCase()
      item.style.display = text.includes(searchTerm) ? "" : "none"
    })
  }

  getItemText(item) {
    if (this.matchOnValue) {
      const el = item.querySelector(this.matchOnValue)
      return el ? el.textContent.trim() : ""
    }
    return item.textContent.trim()
  }
}
