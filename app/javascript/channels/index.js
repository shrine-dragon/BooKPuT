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

  // 初期位置へ移動（アニメーションなし）
  function updateSlider(index, hasAnimation = true) {
    const duration = hasAnimation ? '0.4s' : '0s';
    $wrapper.css({
      'transition': `transform ${duration} ease-out`,
      'transform': `translateX(${index * -240}px)`
    });

    // ドットの連動：(現在のIndex - クローン数) で本物の番号を出す
    let dotIndex = (index - displayCount) % realSlideCount;
    if (dotIndex < 0) dotIndex = realSlideCount + dotIndex;

    $dots.removeClass('active');
    $dots.eq(dotIndex).addClass('active');
  }

  // 初期配置
  updateSlider(currentIndex, false);

  // 右矢印
  $('.next-arrow').off('click').on('click', function() {
    currentIndex++;
    updateSlider(currentIndex);

    // 最後の本物(index=7)を通り過ぎたらワープ
    if (currentIndex >= realSlideCount + displayCount) {
      setTimeout(() => {
        currentIndex = displayCount;
        updateSlider(currentIndex, false);
      }, 400);
    }
  });

  // 左矢印
  $('.prev-arrow').off('click').on('click', function() {
    currentIndex--;
    updateSlider(currentIndex);

    // 最初の本物(index=3)より前に行ったらワープ
    if (currentIndex < displayCount) {
      setTimeout(() => {
        currentIndex = realSlideCount + displayCount - 1;
        updateSlider(currentIndex, false);
      }, 400);
    }
  });

  // ドットクリック（ここが重要！）
  $dots.off('click').on('click', function() {
    // 押されたドットの番号に、クローンのオフセットを足す
    currentIndex = $(this).index() + displayCount;
    updateSlider(currentIndex);
  });
});