import $ from 'jquery';

const loadEvent = (typeof Turbo !== 'undefined') ? 'turbo:load' : 'turbolinks:load';

$(document).on(loadEvent, function() {
  $('.sign-up-btn').on('mouseover', function(){
    $("#modal-overlay").stop(true, true).fadeIn(200); // 背景を暗くする
    $(".modal.sign-up").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.log-in").hide(); // ログインが開いていれば隠す
  });

  $('.log-in-btn').on('mouseover', function(){
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.log-in").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.sign-up").hide(); // 新規登録が開いていれば隠す
  });

  $(document).on('mouseover', function(e) {
    const isInsideSignUp = $(e.target).closest('.modal.sign-up, .sign-up-btn').length;
    const isInsideLogIn = $(e.target).closest('.modal.log-in, .log-in-btn').length;

    // どちらのエリアにもマウスが乗っていない場合のみ消す
    if (!isInsideSignUp && !isInsideLogIn) {
      $("#modal-overlay").fadeOut(200);
      $(".modal.sign-up").fadeOut(200);
      $(".modal.log-in").fadeOut(200);
    }
  });

  $(document).on('keydown', function(e) {
    // キーコード 27 == Escキー
    if (e.keyCode === 27) {
      // 全てのモーダルとオーバーレイを非表示にする
      $("#modal-overlay").fadeOut(200);
      $(".modal.sign-up").fadeOut(200);
      $(".modal.log-in").fadeOut(200);
    }
  });
});