import $ from 'jquery';

const loadEvent = (typeof Turbo !== 'undefined') ? 'turbo:load' : 'turbolinks:load';

$(document).on(loadEvent, function() {
  const isMobileSize = () => window.innerWidth <= 767;

  // 他のモーダルをすべて閉じるヘルパー関数（排他制御）
  function closeAllModals() {
    $(".modal.sign-up").hide();
    $(".modal.log-in").hide();
    $(".modal.log-in-user").hide();
    $(".modal.final-action").hide();
    $("#modal-overlay").hide();
  }

  function openModal($modal, isCenter = true) {
    // 既に開いている最中の場合は重複処理を行わない（チラツキ防止）
    if ($modal.is(':visible')) return;

    closeAllModals();

    if (isCenter) {
      $modal.addClass('is-center');
    } else {
      $modal.removeClass('is-center');
    }
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
  }

  function closeModal($modal) {
    $("#modal-overlay").fadeOut(200);
    $modal.fadeOut(200);
  }

  // 【新規登録モーダル】（テキスト真下に表示 / ホバー＆クリック両対応）
  $('.sign-up-menu').on('mouseover', function() {
    if (isMobileSize()) return;
    openModal($(".modal.sign-up"), false); // 第2引数 false でテキスト直下表示
  });

  $('.sign-up-menu').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

    const $modal = $(".modal.sign-up");
    if ($modal.is(':visible')) {
      closeModal($modal);
    } else {
      openModal($modal, false); // 第2引数 false でテキスト直下表示
    }
  });

  // 【ログインモーダル】（画面中央表示 / ホバー＆クリック両対応）
  $('.log-in-menu').on('mouseover', function() {
    if (isMobileSize()) return;
    openModal($(".modal.log-in"), true); // 常に中央表示
  });

  $('.log-in-menu').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

    const $modal = $(".modal.log-in");
    if ($modal.is(':visible')) {
      closeModal($modal);
    } else {
      openModal($modal, true); // 常に中央表示
    }
  });


  // 【ログイン済みユーザーメニューモーダル】
  $('.user-menu').on('mouseover', function() {
    if (isMobileSize()) return;
    openModal($(".modal.log-in-user"), false);
  });

  $('.user-menu').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

    const $modal = $(".modal.log-in-user");
    if ($modal.is(':visible')) {
      closeModal($modal);
    } else {
      openModal($modal, false);
    }
  });

  // 未ログイン時のアクセス制御（「投稿する」等）
  const $authTrigger = $('[data-auth-trigger="true"]');
  const currentPath = window.location.pathname;

  if ($authTrigger.length > 0 || currentPath === '/users/sign_in') {
    const $logInModal = $(".modal.log-in");

    if ($logInModal.find('.auth-warning-message').length === 0) {
      $logInModal.find('.modal-wrapper').prepend(
        '<div class="auth-warning-message" style="color: red; font-weight: bold; margin-bottom: 20px; text-align: center;">ログインが必要です</div>'
      );
    }

    openModal($logInModal, true);
  }

  // 新規登録ページでログインモーダルを開閉する処理(clickイベント)
  $('.log-in-btn.footer').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

    const $modal = $(".modal.log-in");
    $modal.addClass('is-center');
    
    openModal($modal, true);
  });

  // 背景・Escキー・閉じるボタン処理
  $(document).on('click', '.close-modal, #modal-overlay', function() {
    closeAllModals();
  });

  $(document).on('keydown', function(e) {
    if (e.keyCode === 27) {
      closeAllModals();
    }
  });

  // その他既存処理
  $(document).on('click', '.no-action', function() {
    closeAllModals();
  });

  $(document).on('click', '#destroy-post-btn', function() {
    const bookDeleteUrl = $(this).data('url'); 
    const $modal = $(".modal.final-action.destroy-post");
    $modal.find('#js-destroy-post-link').attr('href', bookDeleteUrl).attr('data-remote', 'false');
    openModal($modal, true);
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
      openModal($('.modal.final-action.report-post'), true);
    }
  });

  $(document).on('click', '.js-destroy-comment-trigger', function() {
    const deleteUrl = $(this).data('url');
    const $modal = $(".modal.final-action.destroy-comment");
    $modal.find('#js-destroy-comment-link').attr('href', deleteUrl).attr('data-remote', 'true');
    openModal($modal, true);
  });

  $(document).on('click', '.js-hide-comment-trigger', function() {
    const hideUrl = $(this).data('url');
    const $modal = $(".modal.final-action.hide-comment");
    $modal.find('#js-hide-comment-link').attr('href', hideUrl);
    openModal($modal, true);
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
      openModal($('.modal.final-action.report-comment'), true);
    }
  });
});