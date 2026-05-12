import $ from 'jquery';

const loadEvent = (typeof Turbo !== 'undefined') ? 'turbo:load' : 'turbolinks:load';

$(document).on(loadEvent, function() {
  // トップページのモーダルの開閉処理(hoverイベント)
  $('.sign-up-menu').on('mouseover', function(){
    $("#modal-overlay").stop(true, true).fadeIn(200); // 背景を暗くする
    $(".modal.sign-up").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.log-in").hide(); // ログインが開いていれば隠す
  });

  $('.log-in-menu').on('mouseover', function(){
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.log-in").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.sign-up").hide(); // 新規登録が開いていれば隠す
  });

  $('.user-menu').on('mouseover', function(){
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.log-in-user").stop(true, true).css("display", "flex").hide().fadeIn(200);
  });

  $(document).on('mouseover', function(e) {
    const $logInModal = $(".modal.log-in");
    const $finalActionModal = $(".modal.final-action");
  
    // ★追加：中央表示モード(.is-center)の時は、マウス移動で消さないようにする
    if ($logInModal.hasClass('is-center') || $finalActionModal.is(':visible')) return;

    const isInsideSignUp = $(e.target).closest('.modal.sign-up, .sign-up-menu').length;
    const isInsideLogIn = $(e.target).closest('.modal.log-in, .log-in-menu').length;
    const isInsideUserMenu = $(e.target).closest('.modal.log-in-user, .user-menu').length;

    // どちらのエリアにもマウスが乗っていない場合のみ消す
    if (!isInsideSignUp && !isInsideLogIn && !isInsideUserMenu) {
      $("#modal-overlay").fadeOut(200);
      $(".modal.sign-up").fadeOut(200);
      $logInModal.fadeOut(200);
      $(".modal.log-in-user").fadeOut(200);
    }
  });

  $(document).on('keydown', function(e) {
    // キーコード 27 == Escキー
    if (e.keyCode === 27) {
      // 全てのモーダルとオーバーレイを非表示にする
      $("#modal-overlay").fadeOut(200);
      $(".modal.sign-up").fadeOut(200);
      $(".modal.log-in").fadeOut(200);
      $(".modal.log-in-user").fadeOut(200);
      $(".modal.final-action").fadeOut(200);
    }
  });
  // 新規登録ページのモーダルの開閉処理(clickイベント)
  $('.log-in-btn.footer').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

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

  // 背景（オーバーレイ）をクリックした時にモーダルを閉じる処理
  $('#modal-overlay, .header, .footer.second').on('click', function(e) {
    // モーダル本体や、その中身をクリックした時は閉じないようにする
    if ($(e.target).closest('.modal').length > 0) {
      return;
    }

    const $logInModal = $(".modal.log-in");
    
    // 背景と全てのモーダルをフェードアウト
    $("#modal-overlay").fadeOut(200);
    $(".modal.sign-up").fadeOut(200);
    $(".modal.log-in-user").fadeOut(200);
    $(".modal.final-action").fadeOut(200);
    
    $logInModal.fadeOut(200, function() {
      if ($logInModal.hasClass('is-center')) {
        $logInModal.removeClass('is-center');
      }
    });
  });
  // ログインに失敗しエラーメッセージがあれば、ログインモーダルを再表示する処理
  if ($('.modal.log-in .error-message').length > 0) {
    const $logInModal = $(".modal.log-in");
    $("#modal-overlay").show();
    // 現在のURL（パス）を取得
    const currentPath = window.location.pathname;

    if (currentPath === '/users/sign_up') {
      $logInModal.addClass('is-center').css("display", "flex");
    } else {
      // ヘッダー用として表示（is-centerを付けない）
      $logInModal.css("display", "flex");
    }
  }

  // 閉じるボタンやno_actionボタンを押した時の挙動
  $(document).on('click', '.no-action, .close-modal', function() {
    $("#modal-overlay").fadeOut(200);
    $(".modal.final-action").fadeOut(200);
  });

  // 投稿そのものの削除ボタン
  $(document).on('click', '#destroy-post-btn', function() {
    const bookDeleteUrl = $(this).data('url'); 
    
    // 削除用モーダルの中にあるリンクを書き換え
    const $modal = $(".modal.final-action.destroy-post");
    $modal.find('#js-destroy-post-link').attr('href', bookDeleteUrl).attr('data-remote', 'false');

    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  // コメントの削除ボタン
  $(document).on('click', '.js-destroy-comment-trigger', function() {
    const deleteUrl = $(this).data('url');
    const $modal = $(".modal.final-action.destroy-comment");
    
    $modal.find('#js-destroy-comment-link').attr('href', deleteUrl).attr('data-remote', 'true');
    
    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  // コメントの非表示ボタン
  $(document).on('click', '.js-hide-comment-trigger', function() {
    const hideUrl = $(this).data('url');
    const $modal = $(".modal.final-action.hide");
    
    $modal.find('#js-hide-link').attr('href', hideUrl);
    
    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  // コメントの通報ボタン
  $(document).on('click', '.js-report-comment-trigger', function() {
    const $btn = $(this);
    const isReported = $btn.attr('data-reported'); // 通報済みかチェック

    if (isReported === 'true') {
      // 【二度目以降】モーダルを出さずにメッセージだけ表示
      $('#flash-container').html('<div class="flash-message alert">通報済みのコメントです</div>');
      if (typeof window.fadeOutFlash === 'function') {
        window.fadeOutFlash();
      }
    } else {
      // 【初めて】モーダルを表示する既存の処理
      const reportUrl = $btn.data('url');
      $('#js-report-link').attr('href', reportUrl);
      $('#modal-overlay').fadeIn(200);
      $('.modal.final-action.report').fadeIn(200);
    }
  });
});