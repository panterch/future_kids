# frozen_string_literal: true

# Filters of the index pages: who may use them, applying them, and keeping
# them between visits. Each index action narrows the records CanCanCan loaded
# by its own strong params:
#
#   def index
#     @kids = filter_index(@kids, kid_params)
#     return if performed? # redirected to the kept or reset filters
#     ...
#
# - Users that may filter the records' model (can?(:filter, Kid) - admins,
#   and principals for kids, see Ability; the views ask the same to show the
#   filter bar) get the index filtered by the params, and their filters are
#   kept for the next visit. @filter is the filter bar's record, a prototype
#   built from the params (application/_filter_bar).
# - All others get the active records only; filter params are ignored.
#
# The filter params are the controller's strong params (e.g. kid_params),
# which must return {} when the request has none - as on the bare index
# path. Filtering by any permitted column is accepted, also for principals
# on kids. Filters that are no column are the model's filter scopes
# (FilterScopes).
#
# Ordering: an order_by param (e.g. the "Ordnen nach" dropdown on kids)
# reorders the index by one or more comma separated columns of the model -
# nothing else, as it goes into the SQL.
#
# Keeping filters: the URL stays the single source of truth. A request
# carrying filter params stores them in the session, a request to the bare
# index path is redirected to that path plus the stored query. The filter
# bar's reset link (?reset_filters=1) drops the stored query. Only the
# model's param key (e.g. kid[...]) and order_by are stored, and the
# redirect target is always request.path - never a stored URL - so
# restoring can't lead off the page. The restored params pass the same
# validation again (strong params, column and order_by checks).
module IndexFilters
  SESSION_KEY = :filters
  RESET_PARAM = 'reset_filters'
  ORDER_PARAM = 'order_by'
  # the session lives in a 4 KB cookie (encrypted and base64 encoded, which
  # adds about a third) shared with Devise and the CSRF token: one page's
  # query and the kept queries of all pages together stay well below it
  MAX_QUERY_BYTES = 1024
  MAX_STORE_BYTES = 1536

  private

  # Returns +records+ filtered and ordered by +filter_params+ and order_by,
  # or redirects to the kept (or reset) filters - see the module comment.
  def filter_index(records, filter_params)
    model = records.klass
    # only reached on indexes non-admins may open, all of users, kids and
    # schools (reminders and kid_mentor_relations are admin only)
    return records.active unless can?(:filter, model)

    remember_filters(model)
    return records if performed?

    # the "Aktiv" filter (application/_inactive_filter) starts on active
    filter = model.column_names.include?('inactive') ? filter_params.with_defaults(inactive: '0') : filter_params
    @filter = model.new(filter)

    records = apply_filters(records, filter)
    order_by = params[ORDER_PARAM].to_s
    valid_order_by?(model, order_by) ? records.reorder(order_by) : records
  end

  # Filters +records+ by the params that name a column of the model and by
  # the model's filter scopes (FilterScopes); blank values ("Alle") don't
  # filter.
  def apply_filters(records, filter)
    model = records.klass
    # stringify: without params the filter is a plain hash with symbol keys
    filter = filter.to_h.stringify_keys.compact_blank
    records = records.where(filter.slice(*model.column_names))
    model.filter_scopes.each do |name|
      records = records.public_send(name, filter[name]) if filter.key?(name)
    end
    records
  end

  # order_by goes into the SQL: only (comma separated) columns of the model
  def valid_order_by?(model, order_by)
    order_by.present? && order_by.split(',').map(&:strip).all? { |column| model.column_names.include?(column) }
  end

  # Stores the filters of this index, or restores (or resets) them by
  # redirecting.
  def remember_filters(model)
    return unless request.get? && request.format.html?
    return reset_filters if params[RESET_PARAM].present?

    current = kept_query(model)
    current.present? ? store_filters(current) : restore_filters
  end

  # the query params kept between visits: the model's filters (e.g. kid[...])
  # and the order
  def kept_query(model)
    request.query_parameters.slice(model.model_name.param_key, ORDER_PARAM)
  end

  # Keeps +filters+ as the most recent page.
  def store_filters(filters)
    filter_store.delete(filter_slot)
    return if filters.to_query.bytesize > MAX_QUERY_BYTES

    filter_store[filter_slot] = filters
    drop_oldest_filters
  end

  # Drops the least recently stored pages while all kept filters together
  # exceed MAX_STORE_BYTES - the current page is always kept.
  def drop_oldest_filters
    store = filter_store
    store.delete(store.keys.first) while store.size > 1 && store.to_json.bytesize > MAX_STORE_BYTES
  end

  def restore_filters
    query = filter_store[filter_slot]&.to_query
    redirect_to "#{request.path}?#{query}" if query.present?
  end

  def reset_filters
    filter_store.delete(filter_slot)
    redirect_to request.path
  end

  # the kept filters of all index pages, one slot per page
  def filter_store
    session[SESSION_KEY] ||= {}
  end

  def filter_slot
    "#{controller_path}##{action_name}"
  end
end
