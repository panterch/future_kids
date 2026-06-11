//= require classnames
//= require react-input-autosize
//= require react-select
//= require underscore

const STYLE_DAY_PLACEHOLDER_WIDTH = 4;
const MAX_MENTORS_TO_DISPLAY = 10;

window.KidMentorSchedules = createReactClass({
  getInitialState() {
    return {
      mentorsToDisplay: getMentorIds(this.props.mentors),
      visitedMentors: [],
      filters: {
        sex: null,
        numberOfKids: 'no-kid',
        school: null,
      },
    };
  },

  getFilteredMentors() {
    const filteredMentors = _.clone(this.props.mentors);
    const total = _.size(this.props.mentors);
    let index = 0;
    for (const [id, mentor] of Object.entries(filteredMentors)) {
      mentor.colors = this.getColorsOfMentor(total, index);
      index++;
      if (this.state.filters?.sex != null) {
        if (mentor.sex !== this.state.filters.sex) delete filteredMentors[id];
      }
      if (this.state.filters?.school != null) {
        if (!mentor.schools.includes(this.state.filters.school)) delete filteredMentors[id];
      }
      if (this.state.filters?.numberOfKids != null) {
        switch (this.state.filters.numberOfKids) {
          case 'primary-only':
            if (!(hasPrimaryKid(mentor) && !hasSecondaryKid(mentor))) delete filteredMentors[id];
            break;
          case 'secondary-only':
            if (!(hasSecondaryKid(mentor) && !hasPrimaryKid(mentor))) delete filteredMentors[id];
            break;
          case 'primary-and-secondary':
            if (!(hasPrimaryKid(mentor) && hasSecondaryKid(mentor))) delete filteredMentors[id];
            break;
          case 'no-kid':
            if (hasPrimaryKid(mentor) || hasSecondaryKid(mentor)) delete filteredMentors[id];
            break;
        }
      }
    }
    return filteredMentors;
  },

  getSelectedMentors(filteredMentors) {
    return limit(_.pick(filteredMentors, this.state.mentorsToDisplay));
  },

  onChangeSelectedMentorsToDisplay(mentorIds, removedMentors) {
    this.setState({ visitedMentors: _.union(this.state.visitedMentors, removedMentors) });
    this.setState({ mentorsToDisplay: mentorIds });
  },

  onChangeFilter(key, value) {
    const filters = this.state.filters;
    filters[key] = value;
    this.setState({ visitedMentors: [] });
    this.setState({ filters });
    this.selectAll();
  },

  selectAll() {
    this.setState({ mentorsToDisplay: _.keys(this.props.mentors) });
  },

  onSelectDate(mentor, day, time) {
    const assigmentText = (mentorLabel) =>
      `Der Mentor wir dem Schüler als ${mentorLabel} zugewiesen.`;

    const alertMentorHasKid = ({ otherKidLabel, mentorLabel }) =>
      `Achtung: \nDieser Mentor ist bereits für den Schüler '${otherKidLabel}' als ${mentorLabel} im Einsatz. Trotzdem dem Schüler zuweisen?\n        (der Mentor bleibt beiden Schülern zugewiesen)`;

    const getConfirmMessage = (assigmentDescription) =>
      `Treffen vereinbaren?\n\n${assigmentDescription}\n\nSchüler: ${displayName(this.props.kid)}\nMentor: ${displayName(mentor)}\nZeitpunkt: ${day.label} um ${time.label}\n\n`;

    const promptAndSave = (mentorType) => {
      let message;
      let mentorKey;
      if (mentorType === 'primary') {
        if (mentor.kids?.length > 0) {
          message = getConfirmMessage(alertMentorHasKid({
            mentorLabel: 'primärer Mentor',
            otherKidLabel: displayName(mentor.kids[0]),
          }));
        } else {
          message = getConfirmMessage(assigmentText('primärer Mentor'));
        }
        mentorKey = 'mentor_id';
      } else if (mentorType === 'secondary') {
        if (mentor.secondary_kids?.length > 0) {
          message = getConfirmMessage(alertMentorHasKid({
            mentorLabel: 'Ersatzmentor*in',
            otherKidLabel: displayName(mentor.secondary_kids[0]),
          }));
        } else {
          message = getConfirmMessage(assigmentText('Ersatzmentor*in'));
        }
        mentorKey = 'secondary_mentor_id';
      }

      if (confirm(message)) {
        const $form = $('#kid_form');
        $form.find(`[name='kid[${mentorKey}]']`).val(mentor.id);
        $form.find("[name='kid[meeting_day]']").val(day.key);
        $form.find("[name='kid[meeting_start_at]']").val(time.key);
        $form.submit();
      }
    };

    if (mentor.id === this.props.kid.mentor_id || mentor.id === this.props.secondary_mentor_id) {
      alert('Dieser Mentor ist diesem Kind bereits zugeteilt.');
    } else if (!hasPrimaryMentor(this.props.kid)) {
      promptAndSave('primary');
    } else if (!hasSecondaryMentor(this.props.kid)) {
      promptAndSave('secondary');
    } else {
      alert('Diesem Kind sind bereits Mentor*in und Ersatzmentor*in zugewiesen');
    }
  },

  getKidsMentor() { return this.props.mentors[this.props.kid.mentor_id]; },
  getKidsSecondaryMentor() { return this.props.mentors[this.props.kid.secondary_mentor_id]; },

  getColorsOfMentor(total, index) {
    const indexShifted = (i) => {
      if (i % 2 === 0) {
        return i / 2;
      } else {
        return Math.floor((i + total) / 2);
      }
    };
    const angle = 360 / total;
    const hue = angle * indexShifted(index);
    return {
      background: `hsla(${hue}, 70%, 90%, 0.5)`,
      text: `hsl(${hue}, 90%, 20%)`,
    };
  },

  render() {
    const filteredMentors = this.getFilteredMentors();
    const selectedMentors = this.getSelectedMentors(filteredMentors);
    const selectedMentorIds = getMentorIds(selectedMentors);
    return React.createElement('div', { className: 'kid-mentor-schedules row' },
      React.createElement('div', { className: 'header panel panel-default' },
        React.createElement('div', { className: 'row' },
          React.createElement('div', { className: 'col-xs-2 title' }, 'Mentoren Filtern: '),
          React.createElement('div', { className: 'col-xs-10' },
            React.createElement(Filters, {
              mentors: this.props.mentors,
              schools: this.props.schools,
              initialFilters: this.state.filters,
              onChange: this.onChangeFilter,
            })
          )
        ),
        React.createElement('div', { className: 'row' },
          React.createElement('div', { className: 'col-xs-2 title' }, 'Mentoren anzeigen: '),
          React.createElement('div', { className: 'col-xs-10' },
            React.createElement(MentorsForDisplayingFilter, {
              mentors: filteredMentors,
              selection: selectedMentorIds,
              onChange: this.onChangeSelectedMentorsToDisplay,
              visitedMentors: this.state.visitedMentors,
            })
          )
        )
      ),
      React.createElement(TimeTable, {
        kid: this.props.kid,
        mentors: selectedMentors,
        onSelectDate: this.onSelectDate,
      })
    );
  },
});

const MentorsForDisplayingFilter = createReactClass({
  DELEMITER: ';',

  onChange(values) {
    const selectedMentorIds = limitAndRemoveFromBeginning(values.map((m) => Number(m.value)));
    this.triggerChange(selectedMentorIds);
  },

  triggerChange(selectedMentorIds) {
    const removedIds = _.difference(this.props.selection, selectedMentorIds);
    this.props.onChange(selectedMentorIds, removedIds);
  },

  selectAll() {
    this.triggerChange(_.keys(this.props.mentors));
  },

  render() {
    let options = [];
    for (const [id, mentor] of Object.entries(this.props.mentors)) {
      options.push({
        visited: parseInt(id, 10) in this.props.visitedMentors,
        label: displayName(mentor),
        value: mentor.id.toString(),
        style: {
          color: mentor.colors.text,
          backgroundColor: mentor.colors.background,
          borderColor: mentor.colors.text,
        },
      });
    }
    options = _.sortBy(options, 'visited');

    const selectedIds = [];
    for (const id of this.props.selection) {
      if (this.props.mentors[id] != null) selectedIds.push(id);
    }
    let value = selectedIds.join(this.DELEMITER);
    if (value.length === 0) value = null;

    const sizeLabel = _.size(this.props.mentors) > MAX_MENTORS_TO_DISPLAY
      ? React.createElement('span', null,
          '(', MAX_MENTORS_TO_DISPLAY, ' von ', _.size(this.props.mentors), ') ',
          React.createElement('br', null),
          React.createElement('strong', null, 'Max. erreicht')
        )
      : React.createElement('span', null, '(', _.size(this.props.mentors), ')');

    const optionRenderer = (option) =>
      React.createElement('span', null,
        option.visited ? React.createElement('i', { className: 'glyphicon glyphicon-eye-open' }) : null,
        ' ',
        option.label
      );

    return React.createElement('div', { className: 'mentors-display-filter row' },
      React.createElement('div', { className: 'col-xs-10' },
        React.createElement(Select, {
          options,
          multi: true,
          optionRenderer,
          delimiter: this.DELEMITER,
          value,
          onChange: this.onChange,
        })
      ),
      React.createElement('button', {
        onClick: this.selectAll,
        className: 'btn btn-default col-xs-2',
      }, 'Alle wählen ', React.createElement('br', null), sizeLabel)
    );
  },
});

const Filters = createReactClass({
  onChangeSex(event) {
    const sanitize = (value) => (['male', 'female', 'diverse'].includes(value) ? value : null);
    this.props.onChange?.('sex', sanitize(event.target.value));
  },

  onChangeSchool(event) {
    const sanitize = (value) => (value.length === 0 ? null : parseInt(value, 10));
    this.props.onChange?.('school', sanitize(event.target.value));
  },

  onChangeNumberOfKids(event) {
    this.props.onChange?.('numberOfKids', event.target.value);
  },

  render() {
    return React.createElement('div', { className: 'filters form-inline' },
      React.createElement('div', { className: 'form-group' },
        React.createElement('label', { htmlFor: 'number-of-kids' }, 'Zeige Mentoren mit '),
        React.createElement('select', {
          name: 'number-of-kids',
          className: 'form-control',
          value: this.props.initialFilters.numberOfKids,
          onChange: this.onChangeNumberOfKids,
        },
          React.createElement('option', { value: 'no-kid' }, 'keinem Schüler zugewiesen'),
          React.createElement('option', { value: 'primary-only' }, 'nur primärem Schüler zugewiesen'),
          React.createElement('option', { value: 'secondary-only' }, 'nur sekundärem Schüler'),
          React.createElement('option', { value: 'primary-and-secondary' }, 'primärem und sekundärem Schüler')
        )
      ),
      React.createElement('div', { className: 'form-group' },
        React.createElement('label', { htmlFor: 'sex' }, 'Geschlecht '),
        React.createElement('select', {
          name: 'sex',
          className: 'form-control',
          value: this.props.initialFilters.sex || '',
          onChange: this.onChangeSex,
        },
          React.createElement('option', null),
          React.createElement('option', { value: 'male' }, 'Männlich'),
          React.createElement('option', { value: 'female' }, 'Weiblich'),
          React.createElement('option', { value: 'diverse' }, 'Divers')
        )
      ),
      React.createElement('div', { className: 'form-group' },
        React.createElement('label', { htmlFor: 'school' }, 'Schule '),
        React.createElement('select', {
          name: 'school',
          className: 'form-control',
          value: this.props.initialFilters.school || '',
          onChange: this.onChangeSchool,
        },
          React.createElement('option', null),
          this.props.schools.map((school) =>
            React.createElement('option', { value: `${school.id}`, key: `${school.id}` }, school.display_name)
          )
        )
      )
    );
  },
});

const TimeTable = createReactClass({
  getInitialState() {
    return {
      //                     mo    di    mi    do    fr
      show_weekdays: [null, true, true, true, true, true],
    };
  },

  createTimeArray() {
    const times = [];
    for (let minutes = 0; minutes <= 360; minutes += 30) {
      const hour = 13 + Math.floor(minutes / 60);
      const minute = minutes % 60;
      const label = `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
      times.push({ key: label, label });
    }
    return times;
  },

  clickHandler_Day(key) {
    return (event) => {
      const new_show_weekdays = this.state.show_weekdays.slice();
      new_show_weekdays[key] = !new_show_weekdays[key];
      this.setState({ show_weekdays: new_show_weekdays });
    };
  },

  render() {
    const days = [
      { key: '1', label: 'Montag' },
      { key: '2', label: 'Dienstag' },
      { key: '3', label: 'Mittwoch' },
      { key: '4', label: 'Donnerstag' },
      { key: '5', label: 'Freitag' },
    ];
    const times = this.createTimeArray();
    const mentors = _.values(this.props.mentors);

    const timeRow = (time, index) => {
      const lastTime = times[index - 1];
      const nextTime = times[index + 1];

      const timeCellHide = (day) => {
        const classes = 'cell-mentor ' + (nextTime ? '' : 'time-last');
        const style = {
          width: STYLE_DAY_PLACEHOLDER_WIDTH + '%',
          cursor: 'pointer',
          backgroundColor: '#EFEFEF',
        };
        return React.createElement('td', {
          key: `time_cell_${day.key}_${time.key}`,
          className: 'time-cell',
          style,
          onClick: this.clickHandler_Day(day.key),
        },
          React.createElement('div', { className: classes },
            React.createElement('span', { className: 'name-label' }, day.label)
          )
        );
      };

      const timeCell = (day) => {
        const kidIsAvailable = availableInSchedule(this.props.kid.schedules, day, time);
        const meetingFixed = parseInt(this.props.kid.meeting_day, 10) === parseInt(day.key, 10) &&
          this.props.kid.meeting_start_at === time.key;
        const hasNoSecondaryMentor = this.props.kid.secondary_mentor_id === null;

        const kidCell = (d, showMeeting) => {
          let kidCellClasses = createTimeCellClasses({
            primaryClass: 'cell-kid',
            day: d,
            lastTime,
            nextTime,
            time,
            schedules: this.props.kid.schedules,
          });
          if (showMeeting) kidCellClasses += ' kid-booked';
          return React.createElement('div', { className: kidCellClasses });
        };

        const mentorCell = (mentor, d) => {
          const onClick = () => { this.props.onSelectDate?.(mentor, d, time); };
          return React.createElement(TimeTable_MentorCell, {
            key: `mentor_cell_${d.key}_${time.key}_${mentor.id}`,
            mentor,
            onClick,
            kidIsAvailable,
            numberOfMentors: _.size(this.props.mentors),
            day: d,
            time,
            lastTime,
            nextTime,
          });
        };

        const classes = classNames('time-cell', { 'kid-available': kidIsAvailable });

        const calcWidth = () => {
          const count = this.state.show_weekdays.filter((d) => d).length;
          return (100 - (days.length - count) * STYLE_DAY_PLACEHOLDER_WIDTH) / count;
        };

        const style = { width: calcWidth() + '%' };
        return React.createElement('td', {
          key: `time_cell_${day.key}_${time.key}`,
          className: classes,
          style,
        },
          kidCell(day, meetingFixed && hasNoSecondaryMentor),
          mentors.map((mentor) => mentorCell(mentor, day))
        );
      };

      return React.createElement('tr', { key: time.key },
        React.createElement('th', null, time.label),
        days.map((day) =>
          this.state.show_weekdays[day.key] ? timeCell(day) : timeCellHide(day)
        )
      );
    };

    const showIcon = React.createElement('span', {
      className: 'glyphicon glyphicon-eye-open',
      style: { display: 'block', textAlign: 'center' },
    });

    return React.createElement('table', { className: 'timetable' },
      React.createElement('thead', null,
        React.createElement('tr', null,
          React.createElement('th', null),
          days.map((day) =>
            React.createElement('th', {
              key: day.key,
              onClick: this.clickHandler_Day(day.key),
              className: `clickable_dayLabel ${day.label}`,
            },
              React.createElement('span', null,
                this.state.show_weekdays[day.key] ? day.label : showIcon
              )
            )
          )
        )
      ),
      React.createElement('tbody', null,
        times.map((time, i) => timeRow(time, i))
      )
    );
  },
});

const TimeTable_MentorCell = createReactClass({
  mentorIsAvailable() {
    return this.props.mentor.schedules?.[this.props.day.key]?.[this.props.time.key] != null;
  },

  render() {
    const mentorColumnWidth = this.props.numberOfMentors > 0
      ? 100 / this.props.numberOfMentors
      : 0;

    if (this.mentorIsAvailable()) {
      const classes = createTimeCellClasses({
        primaryClass: 'column cell-mentor',
        day: this.props.day,
        lastTime: this.props.lastTime,
        nextTime: this.props.nextTime,
        time: this.props.time,
        schedules: this.props.mentor.schedules,
      });
      const style = {
        backgroundColor: this.props.mentor.colors.background,
        color: this.props.mentor.colors.text,
        width: mentorColumnWidth + '%',
      };
      return React.createElement('div', { className: classes, style },
        this.props.kidIsAvailable
          ? React.createElement('a', { className: 'btn-set-date', onClick: this.props.onClick },
              React.createElement('i', { className: 'icon glyphicon glyphicon-calendar' })
            )
          : null,
        React.createElement('span', { className: 'name-label' },
          this.props.mentor.name, ' ', this.props.mentor.prename
        )
      );
    } else {
      return React.createElement('div', {
        className: 'column spacer',
        style: { width: mentorColumnWidth + '%' },
      });
    }
  },
});

// helpers

function limit(mentorsOrArrayOfIds) {
  const limitArray = (arr) => arr.slice(0, MAX_MENTORS_TO_DISPLAY);
  if (_.isArray(mentorsOrArrayOfIds)) {
    return limitArray(mentorsOrArrayOfIds);
  } else {
    return _.pick(mentorsOrArrayOfIds, limitArray(_.keys(mentorsOrArrayOfIds)));
  }
}

function displayName(person) { return `${person.name} ${person.prename}`; }
function limitAndRemoveFromBeginning(mentorIds) {
  return mentorIds.slice(Math.max(mentorIds.length - MAX_MENTORS_TO_DISPLAY, 0));
}
function availableInSchedule(schedules, day, time) {
  return schedules?.[day?.key]?.[time?.key] != null;
}

function hasPrimaryKid(mentor) { return mentor.kids.length > 0; }
function hasSecondaryKid(mentor) { return mentor.secondary_kids.length > 0; }
function hasPrimaryMentor(kid) { return kid.mentor_id != null; }
function hasSecondaryMentor(kid) { return kid.secondary_mentor_id != null; }

function getMentorIds(mentorsObject) {
  return _.keys(mentorsObject).map((id) => parseInt(id, 10));
}

function createTimeCellClasses({ primaryClass, day, lastTime, time, nextTime, schedules }) {
  return classNames(primaryClass, {
    'time-available': availableInSchedule(schedules, day, time),
    'time-first': !availableInSchedule(schedules, day, lastTime),
    'time-last': !availableInSchedule(schedules, day, nextTime),
  });
}
