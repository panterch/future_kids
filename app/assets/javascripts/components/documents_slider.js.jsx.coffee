@DocumentSlider = React.createClass
  render: ->
    React.DOM.div
      className: 'no-sidebar-actions document-slider'
      for categoryName, subcategories of @props.categoryTree
        React.createElement Category, key: categoryName, name: categoryName, subcategories: subcategories, documentsByCategory: @props.documentsByCategory


@Category = React.createClass
  getInitialState: () ->
    open: false
  handleClick: (event) ->
    event.preventDefault()
    @setState open: !@state.open
  render: ->
    key = JSON.stringify([@.props.name, ''])
    documents = @props.documentsByCategory[key] || []
    React.DOM.div
      className: 'panel panel-default'
      React.DOM.div
        className: "panel-heading #{'open' if @state.open}"
        onClick: @handleClick
        @props.name
      React.DOM.div
        className: "list-group #{'open' if @state.open}"
        for document in documents
          React.createElement Document, document
        for subcategoryName in @props.subcategories
          React.createElement Subcategory, categoryName: @props.name, key: subcategoryName, name: subcategoryName, documentsByCategory: @props.documentsByCategory


@Subcategory = React.createClass
  getInitialState: () ->
    open: false
  handleClick: (event) ->
    event.preventDefault()
    @setState open: !@state.open
  render: ->
    key = JSON.stringify([@props.categoryName, @props.name])
    documents = @props.documentsByCategory[key]
    React.DOM.div
      className: 'panel panel-default list-group-item'
      React.DOM.div
        className: "panel-heading #{'open' if @state.open}"
        onClick: @handleClick
        @props.name
      React.DOM.div
        className: "list-group #{'open' if @state.open}"
        for document in documents
          React.createElement Document, document


@Document = React.createClass
  render: ->
    React.DOM.div
      className: 'list-group-item'
      React.DOM.a
        href: @props.link
        @props.title
      React.DOM.div
        className: 'pull-right'
        if @props.destroy_link
          React.DOM.a
            className: 'btn btn-xs btn-default'
            href: @props.destroy_link
            'data-method': 'delete'
            'Löschen'
