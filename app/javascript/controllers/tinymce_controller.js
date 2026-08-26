import { Controller } from "@hotwired/stimulus"

// Reads the live token values so the editor body matches the surrounding page,
// including after a theme switch, instead of hardcoding colours.
function editorStyles() {
  const styles = getComputedStyle(document.documentElement)
  const read = (name, fallback) => (styles.getPropertyValue(name) || fallback).trim()

  return `body {
    font-family: ${read("--font-family-sans", "Inter, sans-serif")};
    font-size: 16px;
    line-height: 1.7;
    color: ${read("--text-primary", "#374151")};
    background: ${read("--bg-surface", "#FFFFFF")};
  }`
}

export default class extends Controller {
  connect() {
    this.initEditor()

    this.onTurboLoad = () => this.reconnect()
    document.addEventListener("turbo:load", this.onTurboLoad)
  }

  disconnect() {
    this.destroy()
    document.removeEventListener("turbo:load", this.onTurboLoad)
  }

  reconnect() {
    if (this.element.isConnected && !this.element.dataset.tinymceInitialized) {
      this.initEditor()
    }
  }

  initEditor() {
    if (typeof tinymce === "undefined") {
      console.warn("TinyMCE not loaded — check the CDN script and TINYMCE_API_KEY")
      return
    }
    if (this.element.dataset.tinymceInitialized) return

    const dark = document.documentElement.getAttribute("data-theme") === "dark" ||
      (!document.documentElement.hasAttribute("data-theme") &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)

    tinymce.init({
      selector: `#${this.element.id}`,
      plugins: "image lists",
      toolbar: "bullist numlist | image",
      menubar: false,
      branding: false,
      skin: dark ? "oxide-dark" : "oxide",
      content_css: dark ? "dark" : "default",
      image_title: true,
      automatic_uploads: true,
      file_picker_types: "image",
      file_picker_callback: (cb, value, meta) => {
        const input = document.createElement("input")
        input.setAttribute("type", "file")
        input.setAttribute("accept", "image/*")
        input.addEventListener("change", (e) => {
          const file = e.target.files[0]
          if (!file) return

          const reader = new FileReader()
          reader.addEventListener("load", () => {
            const id = "blobid" + performance.now()
            const blobCache = tinymce.activeEditor.editorUpload.blobCache
            const base64 = reader.result.split(",")[1]
            const blobInfo = blobCache.create(id, file, base64)
            blobCache.add(blobInfo)
            cb(blobInfo.blobUri(), { title: file.name })
          })
          reader.readAsDataURL(file)
        })
        input.click()
      },
      content_style: editorStyles()
    })

    this.element.dataset.tinymceInitialized = "true"
  }

  destroy() {
    if (typeof tinymce !== "undefined" && this.element.dataset.tinymceInitialized) {
      tinymce.remove(`#${this.element.id}`)
      delete this.element.dataset.tinymceInitialized
    }
  }
}
