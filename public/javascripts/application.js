$(function () {
  register_subnav_expand();
  register_datepickers();
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
  $('#journal_held_at').datepicker();

  $('#journal_start_at, #journal_end_at').calendricalTimeRange({
    isoTime: true,
    minTime: {hour: 13, minute: 0},
    maxTime: {hour: 19, minute: 0},
    timeInterval: 30
  });

}

