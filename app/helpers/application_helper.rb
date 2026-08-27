module ApplicationHelper
  ICON_STYLES = { solid: "fas", regular: "far", brand: "fab" }.freeze

  # Renders a decorative Font Awesome icon. Always aria-hidden: icons in this
  # app sit next to a visible label or inside a button with an aria-label.
  def icon(name, style: :solid, css_class: nil, **)
    classes = [ICON_STYLES.fetch(style, "fas"), "fa-#{name}", css_class].compact.join(" ")
    tag.i("", class: classes, "aria-hidden": "true", **)
  end

  def flash_class(type)
    case type.to_s
    when "notice", "success" then "success"
    when "alert", "error" then "alert"
    else "notice"
    end
  end

  def flash_icon(type)
    case type.to_s
    when "notice", "success" then "check-circle"
    when "alert", "error" then "exclamation-circle"
    else "info-circle"
    end
  end

  def avatar_for(user, size: :md)
    name = user&.name.to_s.strip
    display_name = name.presence || "Unknown user"
    initials = name.present? ? name.split(/\s+/).map(&:first).join.upcase[0, 2] : "?"
    content_tag(:span, initials,
                class: "avatar avatar--#{size} #{avatar_color(display_name)}",
                title: display_name)
  end

  def page_title(title)
    content_for(:page_title) { title }
  end

  # breadcrumb ['Notes', notes_owned_index_path], [@note.title, @note], ['Edit']
  # The last entry is rendered as the current page and is never a link.
  def breadcrumb(*items)
    content_for :breadcrumb do
      safe_join(items.each_with_index.map do |(label, path), index|
        current = index == items.size - 1
        crumb = if current || path.blank?
                  tag.span(label, class: "topbar__breadcrumb-current", "aria-current": "page")
                else
                  link_to(label, path)
                end
        index.zero? ? crumb : safe_join([breadcrumb_separator, crumb])
      end)
    end
  end

  # Mirrors ApplicationController#authorize_note_owner! minus the share case:
  # being able to *read* a shared note does not mean being able to edit it.
  def note_manageable?(note)
    return false unless current_user

    current_user.admin? || note.user_id == current_user.id
  end

  def collection_manageable?(collection)
    return false unless current_user

    current_user.admin? || collection.user_id == current_user.id
  end

  # Exact segment match: a bare start_with? made "/notes_owned" light up
  # "All Notes" (/notes) as well, since one string prefixes the other.
  def nav_active?(path)
    request.path == path || request.path.start_with?("#{path}/")
  end

  # Attributes for a sidebar link, so class and aria-current can never drift.
  def nav_link_attrs(path, extra_class: "sidebar__link")
    active = nav_active?(path)
    { class: [extra_class, ("sidebar__link--active" if active)].compact.join(" "),
      "aria-current": (active ? "page" : nil) }
  end

  # Current path with query params merged/removed. Built from request.path
  # rather than url_for(hash), which re-resolves the route and would drop
  # params it does not recognise.
  def query_url(overrides = {})
    params = request.query_parameters.merge(overrides.stringify_keys)
    params = params.reject { |_, value| value.nil? || value == "" }

    params.any? ? "#{request.path}?#{params.to_query}" : request.path
  end

  def notification_count
    return 0 unless current_user

    @notification_count ||= Notification.where(receiver_id: current_user.id, status: "pending").count
  end

  def time_ago(object)
    return "" unless object.respond_to?(:created_at) && object.created_at

    "#{distance_of_time_in_words(object.created_at, Time.current)} ago"
  end

  private

  def breadcrumb_separator
    tag.span(class: "topbar__breadcrumb-separator", "aria-hidden": "true") { icon("chevron-right") }
  end

  def avatar_color(name)
    colors = %w[avatar--blue avatar--green avatar--orange avatar--red avatar--gray]
    colors[name.chars.sum(&:ord) % colors.length]
  end
end
