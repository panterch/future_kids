# frozen_string_literal: true

# Links and state of an index page's filter bar (application/_filter_bar and
# _filter_dropdown). Who may filter and keeping the filters between visits is
# controller side: IndexFilters.
module FiltersHelper
  # Current path (not url_for, which resolves kids#index to the root route)
  # with the given query params -- used by the filter dropdown links
  # (application/_filter_dropdown), which rebuild the current query string
  # with a single filter changed.
  def filter_path(query)
    "#{request.path}?#{query.to_h.to_query}"
  end

  # Current path with +field+ of a filter set to +value+ ('' for "Alle"),
  # keeping the other filters: nested under the param key of +record+ (the
  # filter bar's prototype, e.g. kid[grade]) or top level without a record
  # (e.g. order_by).
  def filter_option_path(record, field, value)
    query = request.query_parameters
    query = if record
              query.deep_merge(record.model_name.param_key => { field.to_s => value })
            else
              query.merge(field.to_s => value)
            end
    filter_path(query)
  end

  # Label of the option matching the filter's current value, if any. Compares
  # as strings, as option values are e.g. integers or booleans.
  def selected_filter_label(options, current_value)
    options.find { |_, value| value.to_s == current_value.to_s }&.first
  end

  # Current index path without filters, which also drops the filters kept in
  # the session (IndexFilters) - the bare path would restore them.
  def reset_filters_path
    filter_path(IndexFilters::RESET_PARAM => 1)
  end

  # Whether the request filters the index of +record+ (the prototype built
  # from params[<param_key>]): any of those params left it different from an
  # unfiltered prototype. Compares the typecast attributes, so an explicit
  # "Nein" (false) counts while "Alle" ('') and the default "Aktiv" (false,
  # whether sent as 'false' or '0') don't. Only keys naming an assignable
  # attribute (incl. virtual ones like Mentor#filter_by_coach_id) are read --
  # the rest of the query is user input and must not become a method call.
  def filters_active?(record)
    unfiltered = record.class.new
    filters = request.query_parameters.fetch(record.model_name.param_key, {})
    return false unless filters.respond_to?(:keys)

    filters.keys.any? do |field|
      record.respond_to?("#{field}=") &&
        record.public_send(field).to_s != unfiltered.public_send(field).to_s
    end
  end
end
