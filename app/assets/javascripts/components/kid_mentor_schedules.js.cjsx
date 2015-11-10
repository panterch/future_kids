
#= require classnames
#= require react-input-autosize
#= require react-select
#= require underscore
#= require moment

MAX_MENTORS_TO_DISPLAY = 10
@KidMentorSchedules = React.createClass
  getInitialState: ->
    mentorsToDisplay: getMentorIds @props.mentors
    visitedMentors: []
    filters: 
      ects: null
      sex: null
      numberOfKids: "no-kid"
      school: null
  getFilteredMentors: ->
    mentors = @props.mentors
    filteredMentors = _.clone @props.mentors
    index = 0
    total = _.size @props.mentors
    for id, mentor of filteredMentors
      mentor.colors = @getColorsOfMentor total, index
      index++
      if @state.filters?.ects?
        delete filteredMentors[id] if mentor.ects isnt @state.filters.ects
      if @state.filters?.sex?
        delete filteredMentors[id] if mentor.sex isnt @state.filters?.sex
      if @state.filters?.school?
        delete filteredMentors[id] if mentor.primary_kids_school?.id isnt @state.filters?.school
      if @state.filters?.numberOfKids?
        switch @state.filters.numberOfKids
          when 'primary-only' 
            delete filteredMentors[id] unless hasPrimaryKid(mentor) and not hasSecondaryKid(mentor)
          when 'secondary-only'
            delete filteredMentors[id] unless hasSecondaryKid(mentor) and not hasPrimaryKid(mentor)
          when 'primary-and-secondary'
            delete filteredMentors[id] unless hasPrimaryKid(mentor) and hasSecondaryKid(mentor)
          when 'no-kid'
            delete filteredMentors[id] if hasPrimaryKid(mentor) or hasSecondaryKid(mentor)

    return filteredMentors
  getSelectedMentors: (filteredMentors) ->
    limit _.pick filteredMentors, @state.mentorsToDisplay
  onChangeSelectedMentorsToDisplay: (mentorIds, removedMentors) ->
    @setState visitedMentors: _.union @state.visitedMentors, removedMentors
    @setState mentorsToDisplay: mentorIds
  onChangeFilter: (key, value) ->
    filters = @state.filters
    filters[key] = value
    @setState visitedMentors: [] # reset visits
    @setState filters: filters
    # select all mentors, if filter changes
    @selectAll()
  selectAll: ->
    @setState mentorsToDisplay: _.keys @props.mentors
  onSelectDate: (mentor, day, time) ->

    promptAndSave = (mentorType) =>
      assigmentText = (mentorLabel) => 
        "Der Mentor wir dem Schüler als #{mentorLabel} zugewiesen."
      alertMentorHasKid = ({otherKidLabel, mentorLabel}) =>
        "Achtung: \nDieser Mentor ist bereits für den Schüler '#{otherKidLabel}' als #{mentorLabel} im Einsatz. Trotzdem dem Schüler zuweisen? 
        (der Mentor bleibt beiden Schülern zugewiesen)"

      getConfirmMessage = (assigmentDescription)=>
        """
        Treffen vereinbaren?

        #{assigmentDescription}

        Schüler: #{displayName @props.kid}
        Mentor: #{displayName mentor}
        Zeitpunkt: #{day.label} um #{time.label}

        """
      switch mentorType
        when "primary"
          if mentor.kids?.length > 0
            # this mentor has already a primary kid
            message = getConfirmMessage alertMentorHasKid 
              mentorLabel: "primärer Mentor"
              otherKidLabel: displayName mentor.kids[0]
          else
            message = getConfirmMessage assigmentText "primärer Mentor"
          mentorKey = "mentor_id"
        when "secondary"
          if mentor.secondary_kids?.length > 0
            # this mentor has already a primary kid
            message = getConfirmMessage alertMentorHasKid 
              mentorLabel: "Ersatzmentor"
              otherKidLabel: displayName mentor.secondary_kids[0]
          else
            message = getConfirmMessage assigmentText "Ersatzmentor"
          mentorKey = "secondary_mentor_id"
    
      if confirm message
        $form = $ "#kid_form"
        $form.find("[name='kid[#{mentorKey}]']").val mentor.id
        $form.find("[name='kid[meeting_day]']").val day.key
        $form.find("[name='kid[meeting_start_at]']").val time.key
        $form.submit()
    if mentor.id is @props.kid.mentor_id or mentor.id is @props.secondary_mentor_id
      alert "Dieser Mentor ist diesem Kind bereits zugeteilt."
    else if not hasPrimaryMentor @props.kid
      promptAndSave "primary"
    else if not hasSecondaryMentor @props.kid
      promptAndSave "secondary"
    else
      alert "Diesem Kind sind bereits Mentor und Ersatzmentor zugewiesen"

  getKidsMentor: -> @props.mentors[@props.kid.mentor_id]
  getKidsSecondaryMentor: -> @props.mentors[@props.kid.secondary_mentor_id]

  getColorsOfMentor: (total, index) ->
    # we rotate over the color circle to create a color for every mentor
    # but we interval through the mentors, so that neighbor colors are not similar

    indexShifted = (index) -> 
      if index % 2 is 0 
        index / 2
      else
        index = Math.floor (index+total) / 2

    angle = 360 / total
    hue = angle * indexShifted index
    background: "hsla(#{hue}, 70%, 90%, 0.5)"
    text: "hsl(#{hue}, 90%, 20%)"

  render: ->
    filteredMentors = @getFilteredMentors()
    selectedMentors = @getSelectedMentors filteredMentors
    selectedMentorIds = getMentorIds selectedMentors
    <div className="kid-mentor-schedules row">
      <div className="header panel panel-default">
        <div className="row">
          <div className="col-xs-2 title">Mentoren Filtern: </div>
          <div className="col-xs-10">
            <Filters 
              mentors=@props.mentors
              schools=@props.schools
              initialFilters=@state.filters
              onChange=@onChangeFilter
            />
          </div>
        </div>
        <div className="row">
          <div className="col-xs-2 title">Mentoren anzeigen: </div>
          <div className="col-xs-10">
            <MentorsForDisplayingFilter 
              mentors=filteredMentors
              selection=selectedMentorIds
              onChange=@onChangeSelectedMentorsToDisplay
              visitedMentors=@state.visitedMentors
            />
          </div>
        </div>
      </div>
     
      <TimeTable 
        kid=@props.kid
        mentors=selectedMentors
        onSelectDate=@onSelectDate
      />
    </div>

MentorsForDisplayingFilter = React.createClass
  DELEMITER: ";"
  onChange: (valuesAsString) ->
    if valuesAsString? and valuesAsString.length > 0
      values = valuesAsString.split(@DELEMITER).map (id) -> parseInt id, 10
      selectedMentorIds = limitAndRemoveFromBeginning values
    else
      selectedMentorIds = []
    @triggerChange selectedMentorIds

  triggerChange: (selectedMentorIds) ->
    removedIds = _.difference @props.selection, selectedMentorIds
    @props.onChange selectedMentorIds, removedIds

  selectAll: ->
    @triggerChange _.keys @props.mentors
    
  render: ->
    options = for id,mentor of @props.mentors
      visited: parseInt(id,10) in @props.visitedMentors
      label: displayName mentor
      value: mentor.id.toString()
      style: 
        color: mentor.colors.text
        backgroundColor: mentor.colors.background
        borderColor: mentor.colors.text
    options = _.sortBy options, "visited"

    selectedIds = []
    for id in @props.selection # filter out not available values
      selectedIds.push id if @props.mentors[id]?
    value = selectedIds.join @DELEMITER
    if value.length == 0 then value = null
    sizeLabel = 
      if _.size(@props.mentors) > MAX_MENTORS_TO_DISPLAY
        <span>
          ({MAX_MENTORS_TO_DISPLAY} von {_.size @props.mentors}) <br />
          <strong>Max. erreicht</strong>
        </span>
      else
        <span>({_.size @props.mentors})</span>
    optionRenderer = (option) ->
      <span>{if option.visited then <i className='glyphicon glyphicon-eye-open'></i>} {option.label}</span>

    <div className="mentors-display-filter row">
      <div className="col-xs-10">
        <Select 
          options=options 
          multi=true
          optionRenderer=optionRenderer
          delimiter=@DELEMITER
          value=value
          onChange=@onChange
        />
      </div>
      <button 
        onClick=@selectAll
        className="btn btn-default col-xs-2">
          Alle wählen <br />{sizeLabel}
      </button>
    </div>

Filters = React.createClass
  onChangeSex: (event) ->
    sanitize = (value) -> if value is 'm' or value is 'f' then value else null
    @props.onChange? "sex", sanitize event.target.value

  onChangeECTS: (event) ->
    asBoolean = (value) -> switch value 
      when "true" then true
      when "false" then false
      else null
      
    @props.onChange? "ects", asBoolean event.target.value
  onChangeSchool: (event) ->
    sanitize = (value) -> if _.size(value) == 0 then null else parseInt value, 10
    @props.onChange? "school", sanitize event.target.value
  onChangeNumberOfKids: (event) ->
    @props.onChange? "numberOfKids", event.target.value
  render: ->
    <div className="filters form-inline">
      <div className="form-group">
        <label htmlFor="number-of-kids">Zeige Mentoren mit </label>
        <select name="number-of-kids" className="form-control" value=@props.initialFilters.numberOfKids onChange=@onChangeNumberOfKids>
          <option value="no-kid">keinem Schüler zugewiesen</option>
          <option value="primary-only">nur primärem Schüler zugewiesen</option>
          <option value="secondary-only">nur sekundärem Schüler</option>
          <option value="primary-and-secondary">primärem und sekundärem Schüler</option>
        </select>
      </div>

      <div className="form-group">
        <label htmlFor="ects">ECTS </label> 
        <select name="ects" className="form-control" value=@props.initialFilters.ects onChange=@onChangeECTS>
          <option></option>
          <option value="true">ECTS</option>
          <option value="false">kein ECTS</option>
        </select>
      </div>
      <div className="form-group">
        <label htmlFor="sex">Geschlecht </label>
        <select name="sex" className="form-control" value=@props.initialFilters.sex onChange=@onChangeSex>
          <option></option>
          <option value="m">Männlich</option>
          <option value="f">Weiblich</option>
        </select>
      </div>
      <div className="form-group">
        <label htmlFor="school">Schule </label>
        <select name="school" className="form-control" value=@props.initialFilters.school onChange=@onChangeSchool>
          <option></option>
          {
            for school in @props.schools
              <option value="#{school.id}">{school.display_name}</option>
          }
          
        </select>
      </div>
    </div>

TimeTable = React.createClass
  createTimeArray: -> 
    startMoment = moment()
    startMoment.set "hours", 13
    startMoment.set "minutes", 0
    endMoment = moment startMoment
    endMoment.set "hours", 19
    endMoment.set "minutes", 0

    timeMoment = moment startMoment

    while endMoment.diff(timeMoment) >=0
      label = timeMoment.format "HH:mm"
      key = label
      timeMoment.add 30, "minutes"
      {key, label}

  render: ->
    days = [
      (key: "1", label: "Montag")
      (key: "2", label: "Dienstag")
      (key: "3", label: "Mittwoch")
      (key: "4", label: "Donnerstag")
      (key: "5", label: "Freitag")
    ]
    times = @createTimeArray()

    timeRow = (time, index) =>
      lastTime = times[index-1]
      nextTime = times[index+1]

      timeCell = (day) =>
        kidIsAvailable = availableInSchedule @props.kid.schedules, day, time
        #FIXIT: check if start_at time is in range of time-key. It bight not get it now.
        meetingFixed = (parseInt(@props.kid.meeting.day,10) is parseInt(day.key,10) && @props.kid.meeting.start_at is time.key) 
        hasNoSecondaryMentor = if @props.kid.secondary_mentor_id is null then true else false
        
        kidCell = (day, showMeeting) =>
          kidCellClasses = createTimeCellClasses
            primaryClass: "cell-kid"
            day: day
            lastTime: lastTime
            nextTime: nextTime
            time: time
            schedules: @props.kid.schedules
          if showMeeting then kidCellClasses += " kid-booked"
          <div className=kidCellClasses></div>
          # end kidCell

        mentorCell = (mentor, day) =>
          onClick = =>
            @props.onSelectDate? mentor, day, time
          <TimeTable_MentorCell 
            key="mentor_cell_#{day.key}_#{time.key}_#{mentor.id}"
            mentor=mentor 
            onClick=onClick
            kidIsAvailable=kidIsAvailable 
            numberOfMentors={_.size @props.mentors}
            day=day time=time lastTime=lastTime nextTime=nextTime />
          # end mentorCell

        classes = classNames "time-cell", 
          "kid-available": kidIsAvailable

        <td key="time_cell_#{day.key}_#{time.key}" 
          className=classes>
          { kidCell day, (meetingFixed && hasNoSecondaryMentor) }
          { mentorCell mentor, day for mentor in mentors}
        </td>
        # end timecell

      mentors = _.values @props.mentors
      <tr key=time.key>
        <th>{time.label}</th>
        { timeCell day for day in days }
      </tr>
      # end timeRow

    <table className="timetable">
      <thead>
        <tr>
          <th></th>
          { <th key=day.key>{day.label}</th> for day in days }
        </tr>
      </thead>
      <tbody>
      { timeRow time, i for time, i in times }
      </tbody>
    </table>
    # end render

TimeTable_MentorCell = React.createClass
  mentorIsAvailable: ->
    @props.mentor.schedules?[@props.day.key]?[@props.time.key]?
  render: ->
    if @props.numberOfMentors > 0
      mentorColumnWidth = 100 / @props.numberOfMentors
    else
      mentorColumnWidth = 0

    if @mentorIsAvailable()
      classes = createTimeCellClasses
        primaryClass: "column cell-mentor"
        day: @props.day
        lastTime: @props.lastTime
        nextTime: @props.nextTime
        time: @props.time
        schedules: @props.mentor.schedules
      style = 
        backgroundColor: @props.mentor.colors.background
        color: @props.mentor.colors.text, 
        width: mentorColumnWidth+'%'

      <div className=classes style=style>
        {
          if @props.kidIsAvailable
            <a className="btn-set-date" onClick=@props.onClick>
              <i className="icon glyphicon glyphicon-calendar"></i>
            </a>
        }
        <span className="name-label">
          { @props.mentor.name }&nbsp;{ @props.mentor.prename }
        </span>
      </div>
    else
      <div 
        className="column spacer" 
        style={width: mentorColumnWidth+'%'}
        />
# helpers

limit = (mentorsOrArrayOfIds) ->
  limitArray = (arr) -> arr.slice 0, MAX_MENTORS_TO_DISPLAY
  if _.isArray mentorsOrArrayOfIds
    limitArray mentorsOrArrayOfIds
  else
    _.pick mentorsOrArrayOfIds, limitArray _.keys mentorsOrArrayOfIds


displayName = (person) -> "#{person.name} #{person.prename}"    
limitAndRemoveFromBeginning = (mentorIds) -> mentorIds.slice(Math.max(mentorIds.length - MAX_MENTORS_TO_DISPLAY, 0))
availableInSchedule = (schedules, day, time) ->
  schedules?[day?.key]?[time?.key]?

hasPrimaryKid = (mentor) -> mentor.kids.length > 0
hasSecondaryKid = (mentor) -> mentor.secondary_kids.length > 0
hasPrimaryMentor = (kid) -> kid.mentor_id?
hasSecondaryMentor = (kid) -> kid.secondary_mentor_id?

getMentorIds = (mentorsObject) ->
  (parseInt id, 10 for id in _.keys(mentorsObject))

createTimeCellClasses = ({primaryClass, day, lastTime, time, nextTime, schedules}) ->
  classNames primaryClass, 
    'time-available': availableInSchedule schedules, day, time
    'time-first': not availableInSchedule schedules, day, lastTime
    'time-last': not availableInSchedule schedules, day, nextTime

