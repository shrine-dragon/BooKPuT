import $ from 'jquery';

const loadEvent = (typeof Turbo !== 'undefined') ? 'turbo:load' : 'turbolinks:load';

$(document).on(loadEvent, function() {
  function isMobile() {
    return window.innerWidth <= 768;
  }

  // 全モーダルを閉じる共通関数
  function closeAllModals() {
    $("#modal-overlay").stop(true, true).fadeOut(200);
    
    // 【重要】フッターから開いた際に付与したインラインスタイルを消去してリセットする
    $(".modal.log-in").stop(true, true).fadeOut(200, function() {
      $(this).css({
        'top': '',
        'left': '',
        'right': '',
        'transform': '',
        'width': '',
        'border-radius': ''
      });
    });

    $(".modal.sign-up, .modal.log-in-user, .modal.final-action").stop(true, true).fadeOut(200);
  }

  // --- 新規登録メニュー ---
  $('.sign-up-menu').off('mouseover click').on('mouseover', function(){
    if (isMobile()) return;
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.sign-up").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.log-in, .modal.log-in-user").hide();
  }).on('click', function(e){
    if (!isMobile()) return;
    e.preventDefault();
    e.stopPropagation();
    
    const $targetModal = $(".modal.sign-up");

    if ($targetModal.is(':visible')) {
      closeAllModals();
      return;
    }
    
    $(".modal.log-in, .modal.log-in-user").hide();
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $targetModal.stop(true, true).css("display", "flex").hide().fadeIn(200);
  });

  // --- ログインメニュー（2回タップトグル） ---
  $('.log-in-menu').off('mouseover click').on('mouseover', function(){
    if (isMobile()) return;
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.log-in").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.sign-up, .modal.log-in-user").hide();
  }).on('click', function(e){
    if (!isMobile()) return;
    e.preventDefault();
    e.stopPropagation();
    
    const $modal = $(".modal.log-in");

    if ($modal.is(':visible')) {
      closeAllModals();
      return;
    }
    
    $(".modal.sign-up, .modal.log-in-user").hide();
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
  });

  // --- ユーザーメニュー ---
  $('.user-menu').off('mouseover click').on('mouseover', function(){
    if (isMobile()) return;
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $(".modal.log-in-user").stop(true, true).css("display", "flex").hide().fadeIn(200);
    $(".modal.sign-up, .modal.log-in").hide();
  }).on('click', function(e){
    if (!isMobile()) return;
    e.preventDefault();
    e.stopPropagation();
    
    const $modal = $(".modal.log-in-user");

    if ($modal.is(':visible')) {
      closeAllModals();
      return;
    }

    $(".modal.sign-up, .modal.log-in").hide();
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $modal.stop(true, true).css("display", "flex").hide().fadeIn(200);
  });

  // --- マウス移動による自動非表示処理（PCのみ） ---
  $(document).off('mouseover.body').on('mouseover.body', function(e) {
    if (isMobile()) return;

    const $logInModal = $(".modal.log-in");
    const $finalActionModal = $(".modal.final-action");
  
    // 中央表示の判定スタイルを厳密化
    if ($logInModal.is(':visible') && $logInModal.css('transform') !== 'none' && $logInModal.css('transform') !== '') return;
    if ($finalActionModal.is(':visible')) return;

    const isInsideSignUp = $(e.target).closest('.modal.sign-up, .sign-up-menu').length;
    const isInsideLogIn = $(e.target).closest('.modal.log-in, .log-in-menu').length;
    const isInsideUserMenu = $(e.target).closest('.modal.log-in-user, .user-menu').length;

    if (!isInsideSignUp && !isInsideLogIn && !isInsideUserMenu) {
      closeAllModals();
    }
  });

  // --- キーボードイベント ---
  $(document).off('keydown').on('keydown', function(e) {
    if (e.keyCode === 27) {
      closeAllModals();
    }
  });

  // フッターのログインボタン（PC・スマホ共通で中央にポップアップ表示）
  $('.log-in-btn.footer, #destroy-post-btn-alternative-trigger').off('click').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

    const $modal = $(".modal.log-in");
    
    // 中央配置用のスタイルを付与
    $modal.css({
      'display': 'flex',
      'top': '50%',
      'left': '50%',
      'right': 'auto',
      'transform': 'translate(-50%, -50%)',
      'width': isMobile() ? '80%' : '400px',
      'border-radius': '10px',
      'z-index': '9999'
    }).hide(); // 一度hideにしてからfadeInさせる
    
    $("#modal-overlay").stop(true, true).fadeIn(200);
    $modal.stop(true, true).fadeIn(200);
  });

  // 【修正】閉じるボタンのイベントをdocument経由のデリゲーションで確実に発火させる
  $(document).off('click.close').on('click.close', '.close-modal', function(e) {
    e.preventDefault();
    e.stopPropagation();
    closeAllModals();
  });

  $(document).off('click.bg').on('click.bg', function(e) {
    if ($(e.target).closest('.modal, .sign-up-menu, .log-in-menu, .user-menu').length > 0) {
      return;
    }
    closeAllModals();
  });

  // --- 各種アクションモーダル ---
  $(document).off('click.post').on('click.post', '#destroy-post-btn', function() {
    const bookDeleteUrl = $(this).data('url'); 
    const $modal = $(".modal.final-action.destroy-post");
    $modal.find('#js-destroy-post-link').attr('href', bookDeleteUrl).attr('data-remote', 'false');
    $("#modal-overlay").fadeIn(200);
    $modal.fadeIn(200);
  });

  $(document).off('click.report').on('click.report', '.js-report-post-trigger', function(e) {
    const $btn = $(this);
    const isReported = $btn.attr('data-reported');

    if (isReported === true || isReported === 'true') {
      e.preventDefault();
      e.stopPropagation();
      $('#flash-container').html('<div class="flash-message alert">通報済みの投稿です</div>').show();
    } else {
      const reportUrl = $btn.data('url');
      $('#js-report-post-link').attr('href', reportUrl);
      $("#modal-overlay").fadeIn(200);
      $('.modal.final-action.report-post').stop(true, true).fadeIn(200);
    }
  });
});