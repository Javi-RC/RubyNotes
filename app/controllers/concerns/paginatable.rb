# Lightweight server-side pagination and search for Mongoid criteria.
#
# Deliberately dependency-free: Kaminari/Pagy would add a gem for what amounts
# to a skip/limit and a bounds check. Sets @page, @per_page, @total_pages and
# @total_count for `shared/_pagination`, and returns the sliced scope.
#
# Only one paginated list per request is supported (the instance variables are
# shared), which is why the Owned/Shared tabs render one list at a time.
module Paginatable
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 12

  included do
    helper_method :search_query, :searching?
  end

  private

  def paginate(scope, per_page: DEFAULT_PER_PAGE)
    @per_page = per_page
    @total_count = scope.respond_to?(:count) ? scope.count : scope.size
    @total_pages = [(@total_count.to_f / per_page).ceil, 1].max
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @page = @total_pages if @page > @total_pages

    offset = (@page - 1) * per_page

    if scope.respond_to?(:skip)
      scope.skip(offset).limit(per_page)
    else
      Array(scope)[offset, per_page] || []
    end
  end

  # Case-insensitive "contains" match. Regexp.escape keeps user input from
  # being interpreted as a pattern.
  def search_scope(scope, field: :title)
    return scope if search_query.blank?

    scope.where(field => /#{Regexp.escape(search_query)}/i)
  end

  def search_query
    @search_query ||= params[:q].to_s.strip
  end

  def searching?
    search_query.present?
  end
end
