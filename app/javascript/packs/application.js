import jQuery from 'jquery';
window.$ = window.jQuery = jQuery;

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

// プレビュー用のファイルを読み込む（パスに注意！）
import "../channels/index" 
import "../channels/modal"
import "../channels/preview"
import "../channels/flash_messages"
import "../channels/toggle_password"
import "../channels/destroy_account"
import "../channels/auth_failure"
import "../channels/book_contents"
import "../channels/input_title"