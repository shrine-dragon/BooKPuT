// jQueryを読み込んで、グローバル（どこからでも使える状態）に設定する
import jQuery from 'jquery';
window.$ = window.jQuery = jQuery;

// app/javascript/packs/application.js の中身
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

// ここで index.js (または channels フォルダ等) を読み込む
// パスを channels/index に合わせる
import "../channels/index" // index.jsの場所に合わせたパスを指定してください