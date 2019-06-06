import css from '../css/app.scss'
import hljs from 'highlight.js'
import initializeTextComplete from './textComplete'
import jquery from 'jquery'
import qs from 'qs'
import 'phoenix_html'

global.$ = jquery
global.jQuery = jquery
global.hljs = hljs
global.initializeTextComplete = initializeTextComplete
global.qs = qs

hljs.initHighlightingOnLoad()
