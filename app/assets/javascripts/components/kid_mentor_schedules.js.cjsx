
#= require classnames
#= require react-input-autosize
#= require react-select
#= require underscore
#= require moment


TimeTable_MentorButton = React.createClass
  mentorIsAvailable: ->
    console.log  @props.mentor.schedules, @props.day.key
    @props.mentor.schedules?[@props.day.key]?[@props.time.key]?
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
    background: "hsl(#{hue}, 70%, 90%)"
    text: "hsl(#{hue}, 90%, 20%)"

  render: ->
    days = [
      (key: "1", label: "Montag")
      (key: "2", label: "Dienstag")
      (key: "3", label: "Mittwoch")
      (key: "4", label: "Donnerstag")
      (key: "5", label: "Freitag")
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
    <div className="filters">
    
      <select name="ects" value=@props.initialFilters.ects onChange=@onChangeECTS>
        <option></option>
        <option value="true">ECTS</option>
        <option value="false">nur nicht-ECTS</option>
      </select>
      <select name="sex" value=@props.initialFilters.sex onChange=@onChangeSex>
        <option>Beide</option>
        <option value="m">Knabe</option>
        <option value="f">Mädchen</option>
      </select>
      
    </div>

    
@KidMentorSchedules = React.createClass
  getInitialState: ->
    filters: 
      ect: null
      sex: null
  
  getFilteredMentors: ->
    mentors = @props.mentors
    filteredMentors = _.clone @props.mentors
    
    for id, mentor of filteredMentors
      if @state.filters?.ects?
        delete filteredMentors[id] if mentor.ects isnt @state.filters.ects
      if @state.filters?.sex?
        delete filteredMentors[id] if mentor.sex isnt @state.filters?.sex
    return filteredMentors
  
  onChangeFilter: (key, value) ->
    filters = @state.filters
    filters[key] = value
    @setState filters: filters
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

