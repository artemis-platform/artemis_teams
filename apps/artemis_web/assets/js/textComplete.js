import { Textcomplete, Textarea } from 'textcomplete'

const initializeTextComplete = (element, data, symbol) => {
  const options =  {
    dropdown: {
      maxCount: 5,
      placement: 'bottom'
    }
  }

  const editor = new Textarea(element)
  const instance = new Textcomplete(editor, options)

  instance.register([
    textStrategy(data, {symbol: symbol})
  ])

  return instance
}

const textStrategy = (data, options) => {
  const symbol = (options && options.symbol) || '#'
  // CAUTION!
  //
  // When using strings to define a regex, backslashes need to be escaped.
  //
  // For example, this regex:
  //
  //   const match = /(^|\s)#([a-zA-Z0-9+\-\_]*)$/
  //
  // When defined in a string would become:
  //
  //   const regex = '/(^|\\s)#([a-zA-Z0-9+\\-\\_]*)$/'
  //   const match = new RegExp(regex)
  //
  // Notice the additional backslash on values like `\s`, becoming `\\s` instead.
  //
  // Instead of using strings, consider using template literals (backticks)
  // which do not require any additional escaping:
  //
  //   const regex = `/(^|\s)#([a-zA-Z0-9+\-\_]*)$/`
  //   const match = new RegExp(regex)
  //
  const regex = `(^|\\s)${symbol}([a-zA-Z0-9+\\-\\_]*)$`
  const match = new RegExp(regex)

  return {
    id: 'textStrategy',
    match: match,
    search: function (term, callback) {
      callback(Object.keys(data).filter(function (name) {
        return name.startsWith(term)
      }))
    },
    template: function (name) {
      const match = data[name] || {}

      return match.title
    },
    replace: function (name) {
      return '$1' + symbol + name
    }
  }
}

export default initializeTextComplete
