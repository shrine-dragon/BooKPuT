require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import $ from 'jquery';
global.$ = global.jQuery = $;

import "../channels/index" 
import "../channels/modal"
import "../channels/preview"
import "../channels/flash_messages"
import "../channels/toggle_password"
import "../channels/destroy_account"
import "../channels/auth_failure"
import "../channels/input_title"
import "../channels/content_btn"
import "../channels/zoom"
import "../channels/select_genre"
import "../channels/input_comment.js"
import "../channels/view_more_comments.js"
import "../channels/edit_comment.js"