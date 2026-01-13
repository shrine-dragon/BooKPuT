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

  if (window.mySwiperFeature) {
    window.mySwiperFeature.destroy();
  }

  window.mySwiperFeature = new Swiper(".app-feature-wrapper", {
    loop: true,
    slidesPerView: 1,
    autoHeight: true,
    centeredSlides: true, // 中央寄せ
    spaceBetween: 0, // スライド間の隙間
    autoplay: {
      delay: 4000,
      disableOnInteraction: false,
    },
    pagination: {
      el: ".pagination",
      clickable: true,
    },
  });
});