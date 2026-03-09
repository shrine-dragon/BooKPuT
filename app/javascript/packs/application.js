import jQuery from 'jquery';
window.$ = window.jQuery = jQuery;

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import "../channels/index" 
import "../channels/modal"
import "../channels/preview"
import "../channels/flash_messages"
import "../channels/toggle_password"
import "../channels/destroy_account"
import "../channels/auth_failure"
import "../channels/input_title"
import "../channels/content_btn"