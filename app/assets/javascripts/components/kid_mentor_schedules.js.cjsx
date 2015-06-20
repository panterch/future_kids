
#= require classnames
#= require react-input-autosize
#= require react-select
#= require underscore


TimeTable = React.createClass
  
  render: ->
    days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]
    

    <table className="timeTable">
      <thead>
        <tr>
        <th><!--empty--></th>
        {
          <th>{day}</th> for day in days
        }
        </tr>
      </thead>
      <tbody>


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
      
      
    <p>Selected {_.size selectedMentors} mentors of {_.size @props.mentors} 
      <button 
        onClick=@selectAll
        class="btn btn-default">Select All ({_.size @props.mentors})
      </button>
    </p>
      <MentorsForDisplayingFilter 
        mentors=@props.mentors
        initialSelection=selectedMentors
        onChange=@onChange
      />

      <TimeTable 
        kid=@props.kid
        mentors=@props.mentors
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

