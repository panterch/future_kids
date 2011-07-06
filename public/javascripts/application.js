$(function () {
  register_subnav_expand();
  register_datepickers();
  register_journal_controls();
});

// navigation items with further nesting are handled specially:
// they are not displayed, but clicking on the elements above the sub-sub list
function register_subnav_expand() {
  $('ul > li > ul').parents('li').hide();
  $('ul > li > ul').each(function() {
    $(this).parent().prev().click(function() {
		  $(this).next().toggle('fast');
		  return false;
    });
  });
}

// registers jquery ui datepickers on given fields when applicable
function register_datepickers() {

  var date_settings = {
    usa: false,
    separator: '.',
  };

  var time_settings = {
    isoTime: true,
    separator: '.',
    minTime: {hour: 13, minute: 0},
    maxTime: {hour: 19, minute: 0},
    timeInterval: 30
  };

  $('input.calendricalDate').calendricalDate(date_settings);
  $('#journal_start_at, #journal_end_at').calendricalTimeRange(time_settings)
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
