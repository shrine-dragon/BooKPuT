import $ from 'jquery';

$(document).on('turbolinks:load', function() { 
  $('.question-and-answer').off('click').on('click', function(){
    var $answer = $(this).find('.answer');
    if($answer.hasClass('open')){
      $answer.removeClass('open');
      $answer.slideUp();
      $(this).find('span').text('+');
    } else {
      $answer.addClass('open');
      $answer.slideDown();
      $(this).find('span').text('-');
    }
  });

  const $wrapper = $('.post-images');
  const $slides = $('.post-image');
  const $dots = $('.dot');
  let currentIndex = 1; 
  const displayCount = 3;
  const realSlideCount = $slides.length - 2; // ダミー2枚を引いた本物の枚数

  // 初期位置へ移動（アニメーションなし）
  $wrapper.css('transition', 'none');
  $wrapper.css('transform', `translateX(${currentIndex * -240}px)`);

  function updateSlider(index, hasAnimation = true) {
    if (hasAnimation) {
      $wrapper.css('transition', 'transform 0.4s ease-out');
    } else {
      $wrapper.css('transition', 'none');
    }
    $wrapper.css('transform', `translateX(${index * -240}px)`);

    // ドットの更新（ダミーを除いたインデックスで計算）
    let dotIndex = index - 1;
    if (dotIndex >= realSlideCount) dotIndex = 0;
    if (dotIndex < 0) dotIndex = realSlideCount - 1;
    
    $dots.removeClass('active');
    $dots.eq(dotIndex).addClass('active');
  }
  // 右矢印をクリック
  $('.next-arrow').off('click').on('click', function() {
    currentIndex++;
    updateSlider(currentIndex);

    // 最後のダミーに到達したら、アニメーション終了後に本物の1枚目へワープ
    if (currentIndex > realSlideCount) {
      setTimeout(() => {
        currentIndex = 1;
        updateSlider(currentIndex, false);
      }, 400); // transitionの時間(0.4s)と合わせる
    }
  });

  $('.prev-arrow').off('click').on('click', function() {
    currentIndex--;
    updateSlider(currentIndex);

    // 最初のダミーに到達したら、アニメーション終了後に本物の最後へワープ
    if (currentIndex < 1) {
      setTimeout(() => {
        currentIndex = realSlideCount;
        updateSlider(currentIndex, false);
      }, 400);
    }
  });

  // ドットを直接クリックして移動
  $dots.off('click').on('click', function() {
    currentIndex = $(this).index();
    updateSlider(currentIndex);
  });
});