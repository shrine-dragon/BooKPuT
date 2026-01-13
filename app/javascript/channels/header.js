import $ from 'jquery';

const loadEvent = (typeof Turbo !== 'undefined') ? 'turbo:load' : 'turbolinks:load';

$(document).on(loadEvent, function() {
  $('.sign-up-btn').on('mouseover', function(){
    $("#modal-overlay").stop(true, true).fadeIn(200); // 背景を暗くする
    $(".sign-up-modal").stop(true, true).css("display", "flex").hide().fadeIn(200);
  });

  $(document).on('mouseover', function(e) {
    // ボタン、モーダル、どちらにもマウスが乗っていない場合
    if (!$(e.target).closest('.sign-up-modal, .sign-up-btn').length) {
      $("#modal-overlay").fadeOut(200); // 背景を元に戻す
      $(".sign-up-modal").fadeOut(200); // モーダルを隠す
    }
  });
});