$(function () {
  register_subnav_expand();
  register_datepickers();
  register_journal_controls();
  register_mentor_journal_date_selectors();
  register_schedule_checkboxes();
  register_todotogglers();
  register_kidsfilter();
  register_documents_toc();
  register_nav_affix();
  $('input.submit_content_form').click(function() { $('#content_form').submit() } )


});

// affix navigation
// nav gets affixed when scrolling
// nav-wrapper stays on normal flow to assure smooth scrolling
function register_nav_affix() {
  $('#nav').affix({
      offset: { top: $('#nav').offset().top }
  });
  $('#nav-wrapper').height($("#nav").height());
}

// navigation items with further nesting are handled specially:
// they are not displayed, but clicking on the elements above the sub-sub list
function register_subnav_expand() {
  $('#nav ul > li > ul').parents('li').hide();
  $('#nav ul > li > ul').each(function() {
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
    maxTime: {hour: 20, minute: 30},
    timeInterval: 15
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

// on the mentors page, two selectors allow choosing a filter data for journal
function register_mentor_journal_date_selectors() {
  $('select.select_mentor_journal_date').change(function() {
    var href =  window.location.pathname;
    href += '?month='+$('#date_month').val();
    href += '&year='+$('#date_year').val();
    window.location = href;
  });
}

function register_schedule_checkboxes() {
  $('table.schedule input[type=checkbox]').change(function(){
    $(this).siblings('input').toggleEnabled(this.checked) });
  $('table.schedule input[type=checkbox]').each(function(){
    $(this).siblings('input').toggleEnabled(this.checked) });
}

function register_todotogglers() {
  $('a.todotoggle').popover({ placement: 'top', html: true });
}

function register_kidsfilter() {
  $('form.filter select').change(function(event) {
    // alert('change');
    $('form.filter').submit();
  });
}
function register_documents_toc() {
  $('#documents h3, #documents h4').click(function(event) {
    $header = $(this);
    $list = $header.next('ol');
    $header.toggleClass('open');
    $list.toggleClass('open');
  });
}
