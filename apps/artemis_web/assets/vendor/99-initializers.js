function initializeMarkdownTextarea() {
  $('textarea.markdown').each(function() {
    var easyMDE = new EasyMDE({
      element: this,
      spellChecker: false,
      showIcons: ['strikethrough', 'code', 'table', 'redo', 'heading', 'undo', 'heading-1', 'heading-2', 'heading-3', 'heading-4', 'heading-5', 'clean-block', 'horizontal-rule'],
      status: false
    });
  })
}

// Select2
//
// The Select2 library adds enhanced functionality to the default `select` tags.
//
// To use, add the `enhanced` class to any existing `select` tag.
//
// Additional configuration options for Select2 can be configured by adding additional classes.
//
// For example, to add a search bar add the `search` class:
//
//   <%= select f, :example, [1, 2], class: "enhanced search" %>
//
function initializeSelect2() {

  $('select.enhanced').each(function() {
    var item = $(this)
    var classes = item.attr('class').split(' ')
    var options = {}

    // Options
    var hasCreate = classes.includes('creatable') || classes.includes('tags')
    var hasSearch = classes.includes('search')

    options.minimumResultsForSearch = hasSearch ? 0 : Infinity
    options.tags = hasCreate
    options.placeholder = item.attr('placeholder') || ''

    // Initialize
    item.select2(options)
  })
}

function initializeSearchSubmit() {
  // Semantic UI supports inline icons for inputs. For search forms, make the
  // inline search icon double as a submit button.
  $('form.ui').each(function() {
    var form = $(this)
    var containers = form.find('.ui.icon.input')

    containers.each(function() {
      var container = $(this)
      var icon = container.find('i.search')

      icon.click(function(event) {
        form.submit()
      })
    })
  })
}

$(document).ready(function() {
  initializeMarkdownTextarea()
  initializeSelect2()
  initializeSearchSubmit()
})
