import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "rubynotes-theme"

// Cycles light -> dark -> follow the OS. The initial theme is applied by an
// inline script in <head> so the page never paints the wrong theme first.
export default class extends Controller {
  connect() {
    this.sync()
  }

  toggle() {
    const next = { light: "dark", dark: "system", system: "light" }[this.current]
    this.apply(next)
    this.sync()
  }

  apply(theme) {
    try {
      if (theme === "system") {
        localStorage.removeItem(STORAGE_KEY)
      } else {
        localStorage.setItem(STORAGE_KEY, theme)
      }
    } catch (error) {
      // Private mode or blocked storage: the theme still applies for this page.
    }

    if (theme === "system") {
      document.documentElement.removeAttribute("data-theme")
    } else {
      document.documentElement.setAttribute("data-theme", theme)
    }
  }

  sync() {
    const label = { light: "Colour theme: light. Switch to dark.",
                    dark: "Colour theme: dark. Switch to system.",
                    system: "Colour theme: system. Switch to light." }[this.current]
    this.element.setAttribute("aria-label", label)
  }

  get current() {
    const stored = document.documentElement.getAttribute("data-theme")
    return stored === "light" || stored === "dark" ? stored : "system"
  }
}
