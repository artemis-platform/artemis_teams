const Select2Helpers = {}

// Helpers - Phoenix LiveView

Select2Helpers.live_view_hooks = {
  mounted() { global.vendor_initializers.select2() },
  updated() { global.vendor_initializers.select2() }
}

// Exports

export default Select2Helpers
