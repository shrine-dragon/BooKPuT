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
  const $slides = $('.post-image'); // クローン込み全11枚
  const $dots = $('.dot');
  const displayCount = 3;
  const realSlideCount = $slides.length - (displayCount * 2); // 5枚
  
  // 初期位置：前のクローン3枚分を飛ばして「本物の1枚目」へ
  let currentIndex = displayCount;
  let isTransitioning = false; // 連打によるバグ防止

  // 初期位置へ移動（アニメーションなし）
function updateSlider(index, hasAnimation = true) {
    // Amazon Prime風のヌルっとした動きにするためのベジェ曲線
    const easing = 'cubic-bezier(0.25, 1, 0.5, 1)'; 
    const duration = hasAnimation ? '0.6s' : '0s'; // 少し長めにすると高級感が出ます
    
    $wrapper.css({
      'transition': `transform ${duration} ${easing}`,
      'transform': `translateX(${index * -240}px)`
    });

    // ドットの更新：計算式をシンプルに
    let dotIndex = (index - displayCount) % realSlideCount;
    if (dotIndex < 0) dotIndex = realSlideCount + dotIndex;
    $dots.removeClass('active').eq(dotIndex).addClass('active');
  }

  // 初期配置（アニメーションなし）
  updateSlider(currentIndex, false);

  // アニメーション終了時のワープ処理
  $wrapper.on('transitionend', function(e) {
    // 【最重要】ドットの変化など、transform以外のイベントを無視する
    if (e.target !== this || e.originalEvent.propertyName !== 'transform') return;
    
    isTransitioning = false; 

    // 右端（クローン）に達した瞬間に本物の先頭へ
    if (currentIndex >= realSlideCount + displayCount) {
      currentIndex = displayCount;
      // 0sで飛ばす前に、ブラウザに描画を強制させる「おまじない」
      $wrapper.css('transition', 'none'); 
      updateSlider(currentIndex, false);
    }
    // 左端（クローン）に達した瞬間に本物の末尾へ
    else if (currentIndex < displayCount) {
      currentIndex = realSlideCount + displayCount - 1;
      updateSlider(currentIndex, false); // アニメーションなしで位置を戻す
    }
  });

  $('.next-arrow').off('click').on('click', function() {
    if (isTransitioning) return;
    isTransitioning = true;
    currentIndex++;
    updateSlider(currentIndex);
  });

  $('.prev-arrow').off('click').on('click', function() {
    if (isTransitioning) return;
    isTransitioning = true;
    currentIndex--;
    updateSlider(currentIndex);
  });

  $dots.off('click').on('click', function() {
    if (isTransitioning) return;
    // ドットをクリックした瞬間、今の位置と同じなら何もしない
    const targetIndex = $(this).index() + displayCount;
    if (targetIndex === currentIndex) return;

    isTransitioning = true;
    currentIndex = targetIndex;
    updateSlider(currentIndex);
  });
});