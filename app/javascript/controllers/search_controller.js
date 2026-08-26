import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "item"]
  static values = { matchOn: String }

  connect() {
    this.filter()
  }

  filter() {
    const searchTerm = this.inputTarget.value.trim().toLowerCase()
    const items = this.itemTargets

    const exactMatches = []
    const partialMatches = []
    const nonMatches = []

    items.forEach(item => {
      const text = this.getItemText(item).toLowerCase()
      if (searchTerm === "") {
        exactMatches.push(item)
      } else if (text === searchTerm) {
        exactMatches.push(item)
      } else if (text.includes(searchTerm)) {
        partialMatches.push(item)
      } else {
        nonMatches.push(item)
      }
    })

    const sorted = [...exactMatches, ...partialMatches, ...nonMatches]
    sorted.forEach(item => this.listTarget.appendChild(item))
  }

  getItemText(item) {
    if (this.matchOnValue) {
      const el = item.querySelector(this.matchOnValue)
      return el ? el.textContent.trim() : ""
    }
    return item.textContent.trim()
  }
}
