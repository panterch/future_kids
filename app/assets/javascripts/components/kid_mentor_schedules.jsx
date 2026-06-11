//= require classnames
//= require react-input-autosize
//= require react-select

const { useState } = React;

const STYLE_DAY_PLACEHOLDER_WIDTH = 4;
const MAX_MENTORS_TO_DISPLAY = 10;

window.KidMentorSchedules = function KidMentorSchedules({ mentors, schools, kid }) {
  const [mentorsToDisplay, setMentorsToDisplay] = useState(() => getMentorIds(mentors));
  const [visitedMentors, setVisitedMentors] = useState([]);
  const [filters, setFilters] = useState({ sex: null, numberOfKids: 'no-kid', school: null });

  const getColorsOfMentor = (total, index) => {
    const indexShifted = (i) => (i % 2 === 0 ? i / 2 : Math.floor((i + total) / 2));
    const hue = (360 / total) * indexShifted(index);
    return { background: `hsla(${hue}, 70%, 90%, 0.5)`, text: `hsl(${hue}, 90%, 20%)` };
  };

  const getFilteredMentors = () => {
    const filtered = { ...mentors };
    const total = Object.keys(mentors).length;
    let index = 0;
    for (const [id, mentor] of Object.entries(filtered)) {
      mentor.colors = getColorsOfMentor(total, index);
      index++;
      if (filters.sex != null && mentor.sex !== filters.sex) { delete filtered[id]; continue; }
      if (filters.school != null && !mentor.schools.includes(filters.school)) { delete filtered[id]; continue; }
      if (filters.numberOfKids != null) {
        switch (filters.numberOfKids) {
          case 'primary-only':
            if (!(hasPrimaryKid(mentor) && !hasSecondaryKid(mentor))) delete filtered[id];
            break;
          case 'secondary-only':
            if (!(hasSecondaryKid(mentor) && !hasPrimaryKid(mentor))) delete filtered[id];
            break;
          case 'primary-and-secondary':
            if (!(hasPrimaryKid(mentor) && hasSecondaryKid(mentor))) delete filtered[id];
            break;
          case 'no-kid':
            if (hasPrimaryKid(mentor) || hasSecondaryKid(mentor)) delete filtered[id];
            break;
        }
      }
    }
    return filtered;
  };

  const filteredMentors = getFilteredMentors();
  const selectedMentors = limit(
    Object.fromEntries(
      mentorsToDisplay
        .filter(id => String(id) in filteredMentors)
        .map(id => [String(id), filteredMentors[String(id)]])
    )
  );
  const selectedMentorIds = getMentorIds(selectedMentors);

  const onChangeSelectedMentorsToDisplay = (newMentorIds, removedMentors) => {
    setVisitedMentors(prev => [...new Set([...prev, ...removedMentors])]);
    setMentorsToDisplay(newMentorIds);
  };

  const onChangeFilter = (key, value) => {
    setVisitedMentors([]);
    setFilters(prev => ({ ...prev, [key]: value }));
    setMentorsToDisplay(getMentorIds(mentors));
  };

  const onSelectDate = (mentor, day, time) => {
    const assignmentText = (mentorLabel) =>
      `Der Mentor wird dem Schüler als ${mentorLabel} zugewiesen.`;

    const alertMentorHasKid = ({ otherKidLabel, mentorLabel }) =>
      `Achtung: \nDieser Mentor ist bereits für den Schüler '${otherKidLabel}' als ${mentorLabel} im Einsatz. Trotzdem dem Schüler zuweisen?\n        (der Mentor bleibt beiden Schülern zugewiesen)`;

    const confirmMessage = (description) =>
      `Treffen vereinbaren?\n\n${description}\n\nSchüler: ${displayName(kid)}\nMentor: ${displayName(mentor)}\nZeitpunkt: ${day.label} um ${time.label}\n\n`;

    const promptAndSave = (mentorType) => {
      let message, mentorKey;
      if (mentorType === 'primary') {
        message = confirmMessage(
          mentor.kids && mentor.kids.length > 0
            ? alertMentorHasKid({ mentorLabel: 'primärer Mentor', otherKidLabel: displayName(mentor.kids[0]) })
            : assignmentText('primärer Mentor')
        );
        mentorKey = 'mentor_id';
      } else {
        message = confirmMessage(
          mentor.secondary_kids && mentor.secondary_kids.length > 0
            ? alertMentorHasKid({ mentorLabel: 'Ersatzmentor*in', otherKidLabel: displayName(mentor.secondary_kids[0]) })
            : assignmentText('Ersatzmentor*in')
        );
        mentorKey = 'secondary_mentor_id';
      }

      if (confirm(message)) {
        const form = document.getElementById('kid_form');
        form.querySelector(`[name='kid[${mentorKey}]']`).value = mentor.id;
        form.querySelector("[name='kid[meeting_day]']").value = day.key;
        form.querySelector("[name='kid[meeting_start_at]']").value = time.key;
        form.submit();
      }
    };

    if (mentor.id === kid.mentor_id || mentor.id === kid.secondary_mentor_id) {
      alert('Dieser Mentor ist diesem Kind bereits zugeteilt.');
    } else if (!hasPrimaryMentor(kid)) {
      promptAndSave('primary');
    } else if (!hasSecondaryMentor(kid)) {
      promptAndSave('secondary');
    } else {
      alert('Diesem Kind sind bereits Mentor*in und Ersatzmentor*in zugewiesen');
    }
  };

  return (
    <div className="kid-mentor-schedules row">
      <div className="header panel panel-default">
        <div className="row">
          <div className="col-xs-2 title">Mentoren Filtern: </div>
          <div className="col-xs-10">
            <Filters
              mentors={mentors}
              schools={schools}
              initialFilters={filters}
              onChange={onChangeFilter}
            />
          </div>
        </div>
        <div className="row">
          <div className="col-xs-2 title">Mentoren anzeigen: </div>
          <div className="col-xs-10">
            <MentorsForDisplayingFilter
              mentors={filteredMentors}
              selection={selectedMentorIds}
              onChange={onChangeSelectedMentorsToDisplay}
              visitedMentors={visitedMentors}
            />
          </div>
        </div>
      </div>
      <TimeTable kid={kid} mentors={selectedMentors} onSelectDate={onSelectDate} />
    </div>
  );
};

function MentorsForDisplayingFilter({ mentors, selection, onChange, visitedMentors }) {
  const DELIMITER = ';';

  const triggerChange = (selectedMentorIds) => {
    const removedIds = selection.filter(id => !selectedMentorIds.includes(id));
    onChange(selectedMentorIds, removedIds);
  };

  const handleChange = (values) => {
    triggerChange(limitAndRemoveFromBeginning(values.map(m => Number(m.value))));
  };

  const selectAll = () => triggerChange(getMentorIds(mentors));

  let options = Object.entries(mentors).map(([id, mentor]) => ({
    visited: visitedMentors.includes(parseInt(id, 10)),
    label: displayName(mentor),
    value: mentor.id.toString(),
    style: {
      color: mentor.colors.text,
      backgroundColor: mentor.colors.background,
      borderColor: mentor.colors.text,
    },
  }));
  options = [...options].sort((a, b) => Number(a.visited) - Number(b.visited));

  const selectedIds = selection.filter(id => mentors[id] != null);
  const value = selectedIds.length > 0 ? selectedIds.join(DELIMITER) : null;

  const mentorCount = Object.keys(mentors).length;
  const sizeLabel = mentorCount > MAX_MENTORS_TO_DISPLAY
    ? <span>({MAX_MENTORS_TO_DISPLAY} von {mentorCount}) <br /><strong>Max. erreicht</strong></span>
    : <span>({mentorCount})</span>;

  const optionRenderer = (option) => (
    <span>
      {option.visited && <i className="glyphicon glyphicon-eye-open" />}
      {' '}{option.label}
    </span>
  );

  return (
    <div className="mentors-display-filter row">
      <div className="col-xs-10">
        <Select
          options={options}
          multi={true}
          optionRenderer={optionRenderer}
          delimiter={DELIMITER}
          value={value}
          onChange={handleChange}
        />
      </div>
      <button onClick={selectAll} className="btn btn-default col-xs-2">
        Alle wählen <br />{sizeLabel}
      </button>
    </div>
  );
}

function Filters({ mentors, schools, initialFilters, onChange }) {
  const sanitizeSex = (value) => (['male', 'female', 'diverse'].includes(value) ? value : null);
  const sanitizeSchool = (value) => (value.length === 0 ? null : parseInt(value, 10));

  return (
    <div className="filters form-inline">
      <div className="form-group">
        <label htmlFor="number-of-kids">Zeige Mentoren mit </label>
        <select
          name="number-of-kids"
          className="form-control"
          value={initialFilters.numberOfKids}
          onChange={e => onChange && onChange('numberOfKids', e.target.value)}
        >
          <option value="no-kid">keinem Schüler zugewiesen</option>
          <option value="primary-only">nur primärem Schüler zugewiesen</option>
          <option value="secondary-only">nur sekundärem Schüler</option>
          <option value="primary-and-secondary">primärem und sekundärem Schüler</option>
        </select>
      </div>
      <div className="form-group">
        <label htmlFor="sex">Geschlecht </label>
        <select
          name="sex"
          className="form-control"
          value={initialFilters.sex || ''}
          onChange={e => onChange && onChange('sex', sanitizeSex(e.target.value))}
        >
          <option />
          <option value="male">Männlich</option>
          <option value="female">Weiblich</option>
          <option value="diverse">Divers</option>
        </select>
      </div>
      <div className="form-group">
        <label htmlFor="school">Schule </label>
        <select
          name="school"
          className="form-control"
          value={initialFilters.school || ''}
          onChange={e => onChange && onChange('school', sanitizeSchool(e.target.value))}
        >
          <option />
          {schools.map(school => (
            <option value={`${school.id}`} key={`${school.id}`}>{school.display_name}</option>
          ))}
        </select>
      </div>
    </div>
  );
}

function TimeTable({ kid, mentors, onSelectDate }) {
  const [showWeekdays, setShowWeekdays] = useState([null, true, true, true, true, true]);

  const days = [
    { key: '1', label: 'Montag' },
    { key: '2', label: 'Dienstag' },
    { key: '3', label: 'Mittwoch' },
    { key: '4', label: 'Donnerstag' },
    { key: '5', label: 'Freitag' },
  ];

  const times = [];
  for (let minutes = 0; minutes <= 360; minutes += 30) {
    const hour = 13 + Math.floor(minutes / 60);
    const minute = minutes % 60;
    const label = `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
    times.push({ key: label, label });
  }

  const toggleDay = (key) => {
    setShowWeekdays(prev => {
      const next = prev.slice();
      next[key] = !next[key];
      return next;
    });
  };

  const mentorList = Object.values(mentors);
  const mentorCount = Object.keys(mentors).length;

  const calcWidth = () => {
    const visibleCount = showWeekdays.filter(d => d).length;
    return (100 - (days.length - visibleCount) * STYLE_DAY_PLACEHOLDER_WIDTH) / visibleCount;
  };

  return (
    <table className="timetable">
      <thead>
        <tr>
          <th />
          {days.map(day => (
            <th
              key={day.key}
              onClick={() => toggleDay(day.key)}
              className={`clickable_dayLabel ${day.label}`}
            >
              <span>
                {showWeekdays[day.key]
                  ? day.label
                  : <span className="glyphicon glyphicon-eye-open show-icon" />}
              </span>
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {times.map((time, i) => {
          const lastTime = times[i - 1];
          const nextTime = times[i + 1];
          return (
            <tr key={time.key}>
              <th>{time.label}</th>
              {days.map(day => {
                if (!showWeekdays[day.key]) {
                  return (
                    <td
                      key={`time_cell_${day.key}_${time.key}`}
                      className="time-cell day-placeholder"
                      style={{ width: `${STYLE_DAY_PLACEHOLDER_WIDTH}%` }}
                      onClick={() => toggleDay(day.key)}
                    >
                      <div className={`cell-mentor${nextTime ? '' : ' time-last'}`}>
                        <span className="name-label">{day.label}</span>
                      </div>
                    </td>
                  );
                }

                const kidIsAvailable = availableInSchedule(kid.schedules, day, time);
                const meetingFixed =
                  parseInt(kid.meeting_day, 10) === parseInt(day.key, 10) &&
                  kid.meeting_start_at === time.key;
                const kidCellClasses = classNames(
                  createTimeCellClasses({ primaryClass: 'cell-kid', day, lastTime, nextTime, time, schedules: kid.schedules }),
                  { 'kid-booked': meetingFixed && kid.secondary_mentor_id === null }
                );

                return (
                  <td
                    key={`time_cell_${day.key}_${time.key}`}
                    className={classNames('time-cell', { 'kid-available': kidIsAvailable })}
                    style={{ width: `${calcWidth()}%` }}
                  >
                    <div className={kidCellClasses} />
                    {mentorList.map(mentor => (
                      <TimeTableMentorCell
                        key={`mentor_cell_${day.key}_${time.key}_${mentor.id}`}
                        mentor={mentor}
                        onClick={() => onSelectDate && onSelectDate(mentor, day, time)}
                        kidIsAvailable={kidIsAvailable}
                        numberOfMentors={mentorCount}
                        day={day}
                        time={time}
                        lastTime={lastTime}
                        nextTime={nextTime}
                      />
                    ))}
                  </td>
                );
              })}
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}

function TimeTableMentorCell({ mentor, onClick, kidIsAvailable, numberOfMentors, day, time, lastTime, nextTime }) {
  const mentorIsAvailable = mentor.schedules && mentor.schedules[day.key] && mentor.schedules[day.key][time.key] != null;
  const mentorColumnWidth = numberOfMentors > 0 ? 100 / numberOfMentors : 0;

  if (mentorIsAvailable) {
    return (
      <div
        className={createTimeCellClasses({ primaryClass: 'column cell-mentor', day, lastTime, nextTime, time, schedules: mentor.schedules })}
        style={{
          backgroundColor: mentor.colors.background,
          color: mentor.colors.text,
          width: `${mentorColumnWidth}%`,
        }}
      >
        {kidIsAvailable && (
          <a className="btn-set-date" onClick={onClick}>
            <i className="icon glyphicon glyphicon-calendar" />
          </a>
        )}
        <span className="name-label">{mentor.name} {mentor.prename}</span>
      </div>
    );
  }

  return <div className="column spacer" style={{ width: `${mentorColumnWidth}%` }} />;
}

// helpers

function limit(mentorsOrArrayOfIds) {
  const limitArray = (arr) => arr.slice(0, MAX_MENTORS_TO_DISPLAY);
  if (Array.isArray(mentorsOrArrayOfIds)) {
    return limitArray(mentorsOrArrayOfIds);
  } else {
    const limitedKeys = limitArray(Object.keys(mentorsOrArrayOfIds));
    return Object.fromEntries(limitedKeys.map(k => [k, mentorsOrArrayOfIds[k]]));
  }
}

function displayName(person) { return `${person.name} ${person.prename}`; }
function limitAndRemoveFromBeginning(mentorIds) {
  return mentorIds.slice(Math.max(mentorIds.length - MAX_MENTORS_TO_DISPLAY, 0));
}
function availableInSchedule(schedules, day, time) {
  return schedules && day && time && schedules[day.key] && schedules[day.key][time.key] != null;
}
function hasPrimaryKid(mentor) { return mentor.kids.length > 0; }
function hasSecondaryKid(mentor) { return mentor.secondary_kids.length > 0; }
function hasPrimaryMentor(kid) { return kid.mentor_id != null; }
function hasSecondaryMentor(kid) { return kid.secondary_mentor_id != null; }
function getMentorIds(mentorsObject) {
  return Object.keys(mentorsObject).map(id => parseInt(id, 10));
}
function createTimeCellClasses({ primaryClass, day, lastTime, time, nextTime, schedules }) {
  return classNames(primaryClass, {
    'time-available': availableInSchedule(schedules, day, time),
    'time-first': !availableInSchedule(schedules, day, lastTime),
    'time-last': !availableInSchedule(schedules, day, nextTime),
  });
}
