import $ from 'jquery';

const loadEvent = (typeof Turbo !== 'undefined') ? 'turbo:load' : 'turbolinks:load';

$(document).on(loadEvent, function() {
  const isMobileSize = () => window.innerWidth <= 767;

  $('.sign-up-menu').on('mouseover', function() {
    if (isMobileSize()) return;
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.sign-up").stop(true, true).css("display", "flex").hide().fadeIn(200);
  });

  $('.sign-up-menu').on('click', function(e) {
    if (!isMobileSize()) return;
    e.preventDefault();
    e.stopPropagation();

    const $modal = $(".modal.sign-up");
    if ($modal.is(':visible')) {
      $("#modal-overlay").fadeOut(200);
      $modal.fadeOut(200);
    } else {
      $("#modal-overlay").stop(true, true).fadeIn(200);
      $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
    }
  });


  $('.log-in-menu').on('mouseover', function() {
    if (isMobileSize()) return;
    const $modal = $(".modal.log-in");
    $modal.addClass('is-center'); 
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.sign-up").hide();
  });

  $('.log-in-menu').on('click', function(e) {
    e.preventDefault(); // aタグのページ遷移をキャンセルしてモーダルを開く
    e.stopPropagation();

    const $modal = $(".modal.log-in");

    if ($modal.is(':visible')) {
      $("#modal-overlay").fadeOut(200);
      $modal.fadeOut(200, function() {
        $modal.removeClass('is-center');
      });
    } else {
      $modal.addClass('is-center'); // 中央寄せるクラスを付与
      $("#modal-overlay").stop(true, true).fadeIn(200);
      $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
      $(".modal.sign-up").hide();
    }
  });

  $('.user-menu').on('mouseover', function() {
    if (isMobileSize()) return;
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.log-in-user").stop(true, true).css("display", "flex").hide().fadeIn(200);
  });

  $('.user-menu').on('click', function(e) {
    if (!isMobileSize()) return;
    e.preventDefault();
    e.stopPropagation();

    const $modal = $(".modal.log-in-user");
    if ($modal.is(':visible')) {
      $("#modal-overlay").fadeOut(200);
      $modal.fadeOut(200);
    } else {
      $("#modal-overlay").stop(true, true).fadeIn(200);
      $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
    }
  });


  // ページ直アクセス時（/users/sign_in）やエラー時に中央表示させる
  const currentPath = window.location.pathname;
  if (currentPath === '/users/sign_in' || $('.modal.log-in .error-message').length > 0) {
    const $logInModal = $(".modal.log-in");
    $("#modal-overlay").show();
    $logInModal.addClass('is-center').css("display", "flex");
  }

  // 背景クリックやEscキーで閉じる処理
  $(document).on('click', '.close-modal, #modal-overlay', function(e) {
    if ($(e.target).closest('.modal-wrapper').length > 0) return; // モーダル内クリックは無視
    
    const $logInModal = $(".modal.log-in");
    $("#modal-overlay").fadeOut(200);
    $(".modal.sign-up").fadeOut(200);
    $(".modal.log-in-user").fadeOut(200);
    $(".modal.final-action").fadeOut(200);
    
    $logInModal.fadeOut(200, function() {
      $logInModal.removeClass('is-center');
    });
  });

  $(document).on('keydown', function(e) {
    if (e.keyCode === 27) { // ESCキー
      $("#modal-overlay").fadeOut(200);
      $(".modal.log-in").fadeOut(200, function() { $(this).removeClass('is-center'); });
      $(".modal.sign-up, .modal.log-in-user, .modal.final-action").fadeOut(200);
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