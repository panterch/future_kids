
#= require classnames
#= require react-input-autosize
#= require react-select
#= require underscore
#= require moment


TimeTable_MentorButton = React.createClass
  mentorIsAvailable: ->
    # todo, check time and day
    return Math.random() > 0.5
  render: ->
    if @props.numberOfMentors > 0
      mentorColumnWidth = 100 / @props.numberOfMentors
    else
      mentorColumnWidth = 0

    if @mentorIsAvailable()
      <a className="btn-mentor" 
        style={backgroundColor: @props.colors.background, color: @props.colors.text, width: mentorColumnWidth+'%'}>
        {@props.mentor.name}
        <span className="overflow-label" style={backgroundColor: @props.colors.background}>
          {@props.day} {@props.time}
          </span>
      </a>
    else
      <div 
        className="spacer" 
        style={width: mentorColumnWidth+'%'}
        />




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
 
  getColorsOfMentor: (index) ->
    angle = 360 / _.size @props.mentors
    hue = angle *index
    background: "hsl(#{hue}, 70%, 80%)"
    text: "hsl(#{hue}, 90%, 20%)"

  render: ->
    days = [
      (key: "mon", label: "Montag")
      (key: "tue", label: "Dienstag")
      (key: "wed", label: "Mittwoch")
      (key: "thu", label: "Donnerstag")
      (key: "fri", label: "Freitag")
    ]
    times = @createTimeArray()

    <table className="timetable">
      <thead>
        <tr>
        <th></th>
        {
          <th>{day.label}</th> for day in days
        }
        </tr>
      </thead>
      <tbody>
      {
        for time, i in times
          <tr key=time.key>
            <th>{time.label}</th>
            {
              for day in days
                <td className="mentor-column">
                {
                  for mentor, index in _.values @props.mentors
                    <TimeTable_MentorButton 
                      mentor=mentor 
                      numberOfMentors={_.size @props.mentors}
                      colors=@getColorsOfMentor(index)
                      day=day time=time />
                }
                </td>
            }
          </tr>

      } 
      </tbody>
    </table>



Table = React.createClass
  getInitialState: ->

    mentorsToDisplay: @props.initialSelection
  onChange: (mentors) ->
    @setState mentorsToDisplay: mentors
  getSelectedMentors: ->
    mentors = {}

    for id in @state.mentorsToDisplay
      if @props.mentors[id]?
        mentors[id] = @props.mentors[id]

    return mentors
  selectAll: ->
    @setState mentorsToDisplay: _.keys @props.mentors
  render: ->
    selectedMentors = @getSelectedMentors()

    <div>
      
      
    <p>
      Selected {_.size selectedMentors} mentors of {_.size @props.mentors} 
    </p>
      <div className="col-xs-10">
        <MentorsForDisplayingFilter 
          
          mentors=@props.mentors
          initialSelection=selectedMentors
          onChange=@onChange
        />
      </div>
      <button 
        onClick=@selectAll
        className="btn btn-default col-xs-2">Select All ({_.size @props.mentors})
      </button>

      <TimeTable 
        kid=@props.kid
        mentors=selectedMentors
      />
     

    </div>
        
MentorsForDisplayingFilter = React.createClass
  DELEMITER: ";"

  onChange: (valuesAsString) ->
    console.log valuesAsString
    if valuesAsString? and valuesAsString.length > 0
      @props.onChange valuesAsString.split(@DELEMITER).map (id) -> parseInt id, 10
    else
      @props.onChange []
  render: ->
    options = for id,mentor of @props.mentors
      label: "#{mentor.prename} #{mentor.name}"
      value: mentor.id.toString()
    value = (id for id of @props.initialSelection)
    .join ";"
    if value.length == 0 then value = null
    <div className="mentors-filtered">
      <Select 
        options=options 
        multi=true
        delimiter=@DELEMITER
        value=value
        onChange=@onChange
      />


    </div>
Filters = React.createClass

  onChangeGender: (event) ->
    @props.onChange? "gender", event.target.value

  onChangeECTS: (event) ->
    asBoolean = (value) -> switch value 
      when "true" then true
      when "false" then false
      else null
    @props.onChange? "ects", asBoolean event.target.value

  render: ->
    <div className="filters">
    
      <select name="ects" value=@props.initialFilters.ects onChange=@onChangeECTS>
        <option></option>
        <option value="true">ECTS</option>
        <option value="false">nur nicht-ECTS</option>
      </select>
      <select name="gender" value=@props.initialFilters.gender onChange=@onChangeGender>
        <option>Beide</option>
        <option value="m">M</option>
        <option value="f">F</option>
      </select>
      
    </div>

    
@KidMentorSchedules = React.createClass
  getInitialState: ->
    filters: 
      ect: null
      gender: null
  
  
  getFilteredMentors: ->
    mentors = @props.mentors
    filteredMentors = _.clone @props.mentors

    if @state.filters?.ects?
      for id, mentor of filteredMentors
        if @state.filters?.ects
          delete filteredMentors[id] if mentor.ects is null
        else
          delete filteredMentors[id] if mentor.ects is true
    return filteredMentors
  
  onChangeFilter: (key, value) ->
    filters = @state.filters
    filters[key] = value
    @setState filters
  render: ->
    filteredMentors = @getFilteredMentors()
    filteredMentorIds = _.keys filteredMentors
    <div className="kit-mentor-schedules">
      <Filters 
        mentors=@props.mentors
        initialFilters=@state.filters
        onChange=@onChangeFilter
      />
      <Table 
        mentors=filteredMentors
        kid=@props.kid
        initialSelection=filteredMentorIds
        />
      
    </div>

# local Classes

