
#= require classnames
#= require react-input-autosize
#= require react-select
#= require underscore
#= require moment


@KidMentorSchedules = React.createClass
  getInitialState: ->
    mentorsToDisplay: _.keys @props.mentors
    filters: 
      ect: null
      sex: null
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
    return filteredMentors
  getSelectedMentors: (filteredMentors) ->
    _.pick filteredMentors, @state.mentorsToDisplay
  onChangeSelectedMentorsToDisplay: (mentorIds) ->
    @setState mentorsToDisplay: mentorIds
  onChangeFilter: (key, value) ->
    filters = @state.filters
    filters[key] = value
    @setState filters: filters
    # select all mentors, if filter changes
    @selectAll()
  selectAll: ->
    @setState mentorsToDisplay: _.keys @props.mentors
  onSelectDate: (mentor, day, time) ->
    if confirm "Treffen vereinbaren?\n\n
      Schüler: #{@props.kid.prename} #{@props.kid.name}\n
      Mentor: #{mentor.prename} #{mentor.name}\n
      Zeitpunkt: #{day.label} um #{time.label}\n"
      alert "done"
      console.log mentor, day, time
  getColorsOfMentor: (total, index) ->
    # we rotate over the color circle to create a color for every mentor
    # but we skip every second color so that mentors next to each other have not too similar colors
    indexShifted = (index) -> 
      totalEven = total % 2 is 0
      offset = if totalEven and index/total >= 0.5 then 1 else 0
      (index*2+offset) % total

    angle = 360 / total
    hue = angle * indexShifted index
    background: "hsla(#{hue}, 70%, 90%, 0.5)"
    text: "hsl(#{hue}, 90%, 20%)"

  render: ->
    filteredMentors = @getFilteredMentors()
    selectedMentors = @getSelectedMentors filteredMentors

    <div className="kit-mentor-schedules row">
      <div className="header panel panel-default">
        <div className="row">
          <div className="col-xs-2 title">Mentoren Filtern: </div>
          <div className="col-xs-10">
            <Filters 
              mentors=@props.mentors
              initialFilters=@state.filters
              onChange=@onChangeFilter
            />
          </div>
        </div>
        <div className="row">
          <div className="col-xs-2 title">Mentoren Filtern: </div>
          <div className="col-xs-10">
            <MentorsForDisplayingFilter 
              mentors=filteredMentors
              selection=@state.mentorsToDisplay
              onChange=@onChangeSelectedMentorsToDisplay
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
      @props.onChange valuesAsString.split(@DELEMITER).map (id) -> parseInt id, 10
    else
      @props.onChange []
  selectAll: ->
    @props.onChange _.keys @props.mentors
  render: ->
    options = for id,mentor of @props.mentors
      label: "#{mentor.prename} #{mentor.name}"
      value: mentor.id.toString()
      style: 
        color: mentor.colors.text
        backgroundColor: mentor.colors.background
        borderColor: mentor.colors.text
    selectedIds = []
    for id in @props.selection # filter out not available values
      selectedIds.push id if @props.mentors[id]?
    value = selectedIds.join @DELEMITER
    if value.length == 0 then value = null

    <div className="mentors-display-filter row">
      <div className="col-xs-10">
        <Select 
          options=options 
          multi=true
          delimiter=@DELEMITER
          value=value
          onChange=@onChange
        />
      </div>
       <button 
        onClick=@selectAll
        className="btn btn-default col-xs-2">
          Select All ({_.size @props.mentors})
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

  render: ->
    <div className="filters form-inline">
      <div className="form-group">
        <label for="ects">ECTS </label> 
        <select name="ects" className="form-control" value=@props.initialFilters.ects onChange=@onChangeECTS>
          <option></option>
          <option value="true">ECTS</option>
          <option value="false">nur nicht-ECTS</option>
        </select>
      </div>
      <div className="form-group">
        <label for="sex">Geschlecht </label>
        <select name="sex" className="form-control" value=@props.initialFilters.sex onChange=@onChangeSex>
          <option></option>
          <option value="m">Knabe</option>
          <option value="f">Mädchen</option>
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
        kidCell = (day) =>
          kidCellClasses = createTimeCellClasses
            primaryClass: "cell-kid"
            day: day
            lastTime: lastTime
            nextTime: nextTime
            time: time
            schedules: @props.kid.schedules
          <div className=kidCellClasses></div>

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
        classes = classNames "time-cell", 
          "kid-available": kidIsAvailable
        <td key="time_cell_#{day.key}_#{time.key}" 
          className=classes>
          { kidCell day }
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
        primaryClass: "cell-mentor"
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
          { @props.mentor.prename }&nbsp;{ @props.mentor.name }
        </span>
      </div>
    else
      <div 
        className="spacer" 
        style={width: mentorColumnWidth+'%'}
        />
# helpers
availableInSchedule = (schedules, day, time) ->
  schedules?[day?.key]?[time?.key]?
createTimeCellClasses = ({primaryClass, day, lastTime, time, nextTime, schedules}) ->
  classNames primaryClass, 
    'time-available': availableInSchedule schedules, day, time
    'time-first': not availableInSchedule schedules, day, lastTime
    'time-last': not availableInSchedule schedules, day, nextTime

