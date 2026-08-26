import { Controller } from "@hotwired/stimulus"

const FOCUSABLE = 'a[href], button:not([disabled]), input, select, textarea, [tabindex]:not([tabindex="-1"])'

// Off-canvas navigation for narrow viewports. Keeps aria-expanded in sync,
// traps focus while open and returns focus to the toggle on close.
export default class extends Controller {
  static targets = ["sidebar", "overlay", "toggle"]

  connect() {
    this.onKeydown = (event) => this.handleKeydown(event)
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    this.unlockScroll()
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.sidebarTarget.classList.add("sidebar--open")
    this.overlayTarget.classList.add("sidebar-overlay--visible")
    this.setExpanded(true)
    document.body.style.overflow = "hidden"

    const first = this.sidebarTarget.querySelector(FOCUSABLE)
    if (first) first.focus()
  }

  close() {
    if (!this.isOpen) return

    this.sidebarTarget.classList.remove("sidebar--open")
    this.overlayTarget.classList.remove("sidebar-overlay--visible")
    this.setExpanded(false)
    this.unlockScroll()

    if (this.hasToggleTarget) this.toggleTarget.focus()
  }

  handleKeydown(event) {
    if (!this.isOpen) return

    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    } else if (event.key === "Tab") {
      this.trapFocus(event)
    }
  }

  trapFocus(event) {
    const items = Array.from(this.sidebarTarget.querySelectorAll(FOCUSABLE))
      .filter((el) => el.offsetParent !== null)
    if (items.length === 0) return

    const first = items[0]
    const last = items[items.length - 1]

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  setExpanded(value) {
    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", String(value))
      this.toggleTarget.setAttribute("aria-label", value ? "Close navigation" : "Open navigation")
    }
  }

  unlockScroll() {
    document.body.style.overflow = ""
  }

  get isOpen() {
    return this.sidebarTarget.classList.contains("sidebar--open")
  }
}
