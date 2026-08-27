import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "rubynotes-theme"

// The initial theme is applied by an inline script in <head>, so the page
// never paints the wrong one first; this controller only handles the toggle.
//
// From "system" the next theme is the opposite of what is actually on screen,
// not a fixed light -> dark -> system rotation. Rotating blindly meant the
// first click on a light OS moved system -> light, which looks identical: the
// button appeared to do nothing.
export default class extends Controller {
  connect() {
    this.sync()
  }

  toggle() {
    this.apply(this.nextTheme)
    this.sync()
  }

  apply(theme) {
    if (theme === "system") {
      document.documentElement.removeAttribute("data-theme")
    } else {
      document.documentElement.setAttribute("data-theme", theme)
    }

    try {
      if (theme === "system") {
        localStorage.removeItem(STORAGE_KEY)
      } else {
        localStorage.setItem(STORAGE_KEY, theme)
      }
    } catch (error) {
      // Private mode or blocked storage: the theme still applies to this page.
    }
  }

  sync() {
    const labels = {
      light: "Colour theme: light. Switch to dark.",
      dark: "Colour theme: dark. Follow the system setting.",
      system: `Colour theme: system. Switch to ${this.systemPrefersDark ? "light" : "dark"}.`
    }
    this.element.setAttribute("aria-label", labels[this.current])
  }

  get nextTheme() {
    switch (this.current) {
      case "light":
        return "dark"
      case "dark":
        return "system"
      default:
        // Always a visible change, whichever way the OS is set.
        return this.systemPrefersDark ? "light" : "dark"
    }
  }

  get current() {
    const stored = document.documentElement.getAttribute("data-theme")
    return stored === "light" || stored === "dark" ? stored : "system"
  }

  get systemPrefersDark() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
  }
}
