import "@hotwired/turbo-rails"

// Auto-dismiss toasts after 4 seconds
document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".toast").forEach((toast) => {
    setTimeout(() => toast.remove(), 4000)
  })
})
