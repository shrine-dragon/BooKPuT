import $ from 'jquery';

const loadEvent = (typeof Turbo !== 'undefined') ? 'turbo:load' : 'turbolinks:load';

$(document).on(loadEvent, function() {
  // トップページのモーダルの開閉処理(hoverイベント)
  $('.sign-up-hover').on('mouseover', function(){
    $("#modal-overlay").stop(true, true).fadeIn(200); // 背景を暗くする
    $(".modal.sign-up").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.log-in").hide(); // ログインが開いていれば隠す
  });

  $('.log-in-hover').on('mouseover', function(){
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.log-in").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.sign-up").hide(); // 新規登録が開いていれば隠す
  });

  $(document).on('mouseover', function(e) {
    const $logInModal = $(".modal.log-in");
  
    // ★追加：中央表示モード(.is-center)の時は、マウス移動で消さないようにする
    if ($logInModal.hasClass('is-center')) return;

    const isInsideSignUp = $(e.target).closest('.modal.sign-up, .sign-up-hover').length;
    const isInsideLogIn = $(e.target).closest('.modal.log-in, .log-in-hover').length;

    // どちらのエリアにもマウスが乗っていない場合のみ消す
    if (!isInsideSignUp && !isInsideLogIn) {
      $("#modal-overlay").fadeOut(200);
      $(".modal.sign-up").fadeOut(200);
      $logInModal.fadeOut(200);
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
  // 新規登録ページのモーダルの開閉処理(clickイベント)
$('.log-in-btn.footer').on('click', function(e) {
    e.preventDefault();

    console.log('こんにちは');
    
    const $modal = $(".modal.log-in");
    
    // 中央配置用のクラスを付与
    $modal.addClass('is-center');
    
    // 背景とモーダルを表示
    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  // バツボタンで閉じる時の処理
  $(document).on('click', '.close-modal', function() {
    const $modal = $(".modal.log-in");
    $("#modal-overlay").fadeOut(200);
    $modal.fadeOut(200, function() {
        // 閉じた後は中央用クラスを外して、ヘッダー用に戻しておく
        $modal.removeClass('is-center');
    });
  });
});