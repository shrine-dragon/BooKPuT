import $ from 'jquery';

const loadEvent = (typeof Turbo !== 'undefined') ? 'turbo:load' : 'turbolinks:load';

$(document).on(loadEvent, function() {
  // スマホ判定の基準値（scssの@include mobileと同期。一般的には767pxまたは480px等）
  const isMobileSize = () => window.innerWidth <= 767;

  // 新規登録モーダルの制御
  // PC: mouseover で開く
  $('.sign-up-menu').on('mouseover', function() {
    if (isMobileSize()) return; // スマホ時は何もしない
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.sign-up").stop(true, true).css("display", "flex").hide().fadeIn(200);
    // $(".modal.log-in").hide();
  });

  // スマホ: タップ（click）で開閉（トグル）
  $('.sign-up-menu').on('click', function(e) {
    if (!isMobileSize()) return; // PC時は何もしない
    e.preventDefault();
    e.stopPropagation(); // バブリング停止

    const $modal = $(".modal.sign-up");

    // 💡 すでに開いている場合は閉じる（2回目のタップ）
    if ($modal.is(':visible')) {
      $("#modal-overlay").fadeOut(200);
      $modal.fadeOut(200);
    } else {
      // 閉じている場合は開く（1回目のタップ）
      $("#modal-overlay").stop(true, true).fadeIn(200);
      $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
      // $(".modal.log-in").hide();
    }
  });

  // 【ログインメニュー】のアクション無効化（スマホのみ）
  // PC: mouseover で開く
  // $('.log-in-menu').on('mouseover', function() {
  //   if (isMobileSize()) return; // スマホ時は別ページ遷移にするため無効化
  //   $("#modal-overlay").stop(true, true).fadeIn(200);
  //   $(".modal.log-in").stop(true, true).css("display", "flex").hide().fadeIn(200);
  //   $(".modal.sign-up").hide();
  // });

  // スマホ: ログインメニューをクリックした場合は、モーダルを開かずそのまま通常のaタグ（別ページ遷移など）の挙動をさせる
  // $('.log-in-menu').on('click', function(e) {
  //   if (isMobileSize()) {
  //     // ログインページを別で作成しているとのことですので、
  //     // 必要に応じてここに `window.location.href = '/users/sign_in';` のように直接遷移させても良いです。
  //     // モーダル処理は一切行いません。
  //     return; 
  //   }
  // });

  // 【ユーザーメニューモーダル】の制御
  // PC: mouseover で開く
  $('.user-menu').on('mouseover', function() {
    if (isMobileSize()) return; // スマホ時は何もしない
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.log-in-user").stop(true, true).css("display", "flex").hide().fadeIn(200);
  });

  // スマホ: タップ（click）で開閉（トグル）
  $('.user-menu').on('click', function(e) {
    if (!isMobileSize()) return; // PC時は何もしない
    e.preventDefault();
    e.stopPropagation();

    const $modal = $(".modal.log-in-user");

    // 💡 すでに開いている場合は閉じる（2回目のタップ）
    if ($modal.is(':visible')) {
      $("#modal-overlay").fadeOut(200);
      $modal.fadeOut(200);
    } else {
      // 閉じている場合は開く（1回目のタップ）
      $("#modal-overlay").stop(true, true).fadeIn(200);
      $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
    }
  });

  // 【PC用：マウスアウトで閉じる処理】の改良
  $(document).on('mouseover', function(e) {
    if (isMobileSize()) return; // スマホ時は画面移動で閉じないようにする

    const $logInModal = $(".modal.log-in");
    const $finalActionModal = $(".modal.final-action");
  
    if ($logInModal.hasClass('is-center') || $finalActionModal.is(':visible')) return;

    const isInsideSignUp = $(e.target).closest('.modal.sign-up, .sign-up-menu').length;
    const isInsideLogIn = $(e.target).closest('.modal.log-in, .log-in-menu').length;
    const isInsideUserMenu = $(e.target).closest('.modal.log-in-user, .user-menu').length;

    if (!isInsideSignUp && !isInsideLogIn && !isInsideUserMenu) {
      $("#modal-overlay").fadeOut(200);
      $(".modal.sign-up").fadeOut(200);
      $logInModal.fadeOut(200);
      $(".modal.log-in-user").fadeOut(200);
    }
  });

  $(document).on('keydown', function(e) {
    if (e.keyCode === 27) {
      $("#modal-overlay").fadeOut(200);
      $(".modal.sign-up").fadeOut(200);
      $(".modal.log-in").fadeOut(200);
      $(".modal.log-in-user").fadeOut(200);
      $(".modal.final-action").fadeOut(200);
    }
  });

  $('.log-in-btn.footer').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();
    const $modal = $(".modal.log-in");
    $modal.addClass('is-center');
    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  $(document).on('click', '.close-modal', function() {
    const $modal = $(".modal.log-in");
    $("#modal-overlay").fadeOut(200);
    $modal.fadeOut(200, function() {
        $modal.removeClass('is-center');
    });
  });

  $('#modal-overlay, .header, .footer.second').on('click', function(e) {
    if ($(e.target).closest('.modal').length > 0) {
      return;
    }
    const $logInModal = $(".modal.log-in");
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

  if ($('.modal.log-in .error-message').length > 0) {
    const $logInModal = $(".modal.log-in");
    $("#modal-overlay").show();
    const currentPath = window.location.pathname;
    if (currentPath === '/users/sign_up') {
      $logInModal.addClass('is-center').css("display", "flex");
    } else {
      $logInModal.css("display", "flex");
    }
  }

  $(document).on('click', '.no-action, .close-modal', function() {
    $("#modal-overlay").fadeOut(200);
    $(".modal.final-action").fadeOut(200);
  });

  $(document).on('click', '#destroy-post-btn', function() {
    const bookDeleteUrl = $(this).data('url'); 
    const $modal = $(".modal.final-action.destroy-post");
    $modal.find('#js-destroy-post-link').attr('href', bookDeleteUrl).attr('data-remote', 'false');
    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  $(document).on('click', '.js-report-post-trigger', function(e) {
    const $btn = $(this);
    const isReported = $btn.attr('data-reported');
    if (isReported === true || isReported === 'true') {
      e.preventDefault();
      e.stopPropagation();
      $('#flash-container').html('<div class="flash-message alert">通報済みの投稿です</div>');
      if (typeof window.fadeOutFlash === 'function') {
        window.fadeOutFlash();
      }
    } else {
      const reportUrl = $btn.data('url');
      $('#js-report-post-link').attr('href', reportUrl);
      $("#modal-overlay").fadeIn(200);
      $('.modal.final-action.report-post').fadeIn(200);
    }
  });

  $(document).on('click', '.js-destroy-comment-trigger', function() {
    const deleteUrl = $(this).data('url');
    const $modal = $(".modal.final-action.destroy-comment");
    $modal.find('#js-destroy-comment-link').attr('href', deleteUrl).attr('data-remote', 'true');
    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  $(document).on('click', '.js-hide-comment-trigger', function() {
    const hideUrl = $(this).data('url');
    const $modal = $(".modal.final-action.hide-comment");
    $modal.find('#js-hide-comment-link').attr('href', hideUrl);
    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  $(document).on('click', '.js-report-comment-trigger', function(e) {
    const $btn = $(this);
    const isReported = $btn.attr('data-reported');
    if (isReported === true || isReported === 'true') {
      e.preventDefault();
      e.stopPropagation();
      $('#flash-container').html('<div class="flash-message alert">通報済みのコメントです</div>');
      if (typeof window.fadeOutFlash === 'function') {
        window.fadeOutFlash();
      }
    } else {
      const reportUrl = $btn.data('url');
      $('#js-report-comment-link').attr('href', reportUrl);
      $("#modal-overlay").fadeIn(200);
      $('.modal.final-action.report-comment').fadeIn(200);
    }
  });
});