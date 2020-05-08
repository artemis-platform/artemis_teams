const Select2Helpers = {}

// Helpers - Phoenix LiveView

Select2Helpers.live_view_hooks = {
  mounted() {
    console.log("mounted!", global.vendor_initializers)
    global.vendor_initializers.select2()
  },
  updated() {
    console.log("updated!", global.vendor_initializers)
    global.vendor_initializers.select2()
  }
}

// Exports

export default Select2Helpers
