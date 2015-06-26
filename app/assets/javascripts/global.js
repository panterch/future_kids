"use strict";

$(function () {
  register_datepickers();
  register_journal_controls();
  register_mentor_journal_date_selectors();
  register_schedule_checkboxes();
  register_todotogglers();
  register_kidsfilter();
  register_kidanchors();
  register_submit_action_in_sidebar();
  register_back_to_top_link();
  register_exit_at_toggler();
  setTimeout(remove_alerts, 3000);
});

// registers jquery ui datepickers on given fields when applicable
function register_datepickers() {

  var date_settings = {
    usa: false,
    separator: '.'
  };

  var time_settings = {
    isoTime: true,
    separator: '.',
    minTime: {hour: 13, minute: 0},
    maxTime: {hour: 20, minute: 30},
    timeInterval: 15
  };

  $('input.calendricalDate').calendricalDate(date_settings);
  $('#journal_start_at, #journal_end_at').calendricalTimeRange(time_settings);
  $('#kid_meeting_start_at').calendricalTime(time_settings);

}

// register active features on the journal entry form
function register_journal_controls() {
  $('#journal_cancelled').change(function() {
    var show_times = !($(this).is(':checked'));
    $('#journal_start_at_input, #journal_end_at_input').toggle(show_times);
  });
  $('#journal_cancelled').change();
}

// on the mentors page, two selectors allow choosing a filter data for journal
function register_mentor_journal_date_selectors() {
  $('select.select_mentor_journal_date').change(function() {
    var href =  window.location.pathname;
    href += '?month='+$('#date_month').val();
    href += '&year='+$('#date_year').val();
    href += '#mentor_journal_date';
    window.location = href;
  });
}

function register_schedule_checkboxes() {
  $('form.schedule table input[type=checkbox]').change(function(){
    $(this).siblings('input').toggleEnabled(this.checked); });
  $('form.schedule table input[type=checkbox]').each(function(){
    $(this).siblings('input').toggleEnabled(this.checked); });
}

function register_todotogglers() {
  $('a.todotoggle').popover({
    placement: 'left',
    trigger: 'hover',
    html: true
  });
}

function register_kidsfilter() {
  $('form.filter select, form.filter input').change(function() {
    $('form.filter').submit();
  });
}

function register_kidanchors() {
  $('#sidebar .kidanchors a').click(function(event) {
    event.preventDefault();

    var target = this.hash,
    $target = $(target);

    $('html, body').stop().animate({
      'scrollTop': $target.offset().top - $('#header').height() - 3
    }, 500, 'swing');
  });
}

function register_submit_action_in_sidebar() {
  $('#main form input[type=submit]').each(function() {
    var $original = $(this);
    if ($original.parents('.no-sidebar-actions').length) { return; }
    var $clone = $('<a href="#" class="list-group-item list-group-item-success">');
    $clone.text($original.val());
    $clone.click(function(event) {
      event.preventDefault();
      $original.click();
    });
    $clone.prependTo($('#contextual_links_panel .list-group'));
  });
}

function register_back_to_top_link() {
  if ($("body").height() < $(window).height()) { return; }
  var $toTop = $('<a href="#" class="list-group-item">');
  $toTop.text('Seitenanfang');
  $toTop.click(function(event) {
    event.preventDefault();
    $('html, body').stop().animate({ 'scrollTop': 0 }, 500, 'swing');
  });
  $toTop.appendTo($('#contextual_links_panel .list-group'));
}

function register_exit_at_toggler() {
  $('#kid_exit_kind, #mentor_exit_kind').change(function() {
    $('.form-group.kid_exit_at, .form-group.mentor_exit_at').toggle('later' == $(this).val());
  });
  $('#kid_exit_kind, #mentor_exit_kind').change();
}

function remove_alerts() {
  $('.alert').fadeOut();
}
