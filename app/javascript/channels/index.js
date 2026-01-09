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
});