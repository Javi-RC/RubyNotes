import { Controller } from "@hotwired/stimulus"

const AUTO_DISMISS_MS = 5000

// Auto-dismiss, unless the message is an error (role=alert) — those stay until
// dismissed, so a failure never disappears before it has been read.
export default class extends Controller {
  connect() {
    if (this.element.getAttribute("role") === "alert") return

    this.timeout = setTimeout(() => this.dismiss(), AUTO_DISMISS_MS)
  }

  disconnect() {
    clearTimeout(this.timeout)
    clearTimeout(this.removal)
  }

  dismiss() {
    clearTimeout(this.timeout)

    // The exit animation lives in CSS so prefers-reduced-motion applies.
    this.element.classList.add("flash--dismissing")

    const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.removal = setTimeout(() => this.element.remove(), reduced ? 0 : 300)
  }
}
