# This class handles the public api for events.
#
# The documentation will be generated by the apipie gem
# and is accessible through the `/api` path.
#
class Api::V1::Public::EventsController < Api::V1::PublicController

  expose :group, -> { Group.find(params[:group_id]) if params[:group_id] }

  api :GET, '/api/v1/public/events', "List all public events that are to be published on the global website."
  api :GET, '/api/v1/public/groups/123/events', "List all public events of the given group and its subgroups that are to be published on the group's public website."

  param :year, :number, "Only list events in the given year. If a term is given and if the term continues in the next year, these events are also included."
  param :term, ["winter_term", "summer_term"], desc: 'For example: `/api/v1/public/groups/123/events.json?term=winter_term&year=2016`.'
  param :limit, :number, "Only show this number of upcoming events. If no limit is given, all events are listed, not only upcoming events."

  def index
    authorize! :index_public_events, :all

    begin
      render json: events.order(:start_at).as_json(methods: [:url])
    rescue => exception
      render json: {error: exception.to_s}, status: :bad_request
    end
  end

  private

  def events
    if group
      @events = group.events_with_subgroups.where(publish_on_local_website: true)
    else
      @events = Event.where(publish_on_global_website: true)
    end

    if params[:year] && !params[:term]
      year = DateTime.new(params[:year].to_i)
      @events = @events.where(start_at: year.beginning_of_year..year.end_of_year)
    elsif params[:year] && params[:term]
      type = (params[:term] == 'summer_term') ? 'Terms::Summer' : 'Terms::Winter'
      @events = @events.where(start_at: Term.by_year_and_type(params[:year], type).time_range)
    elsif !params[:year] && params[:term]
      raise 'no year given'
    end

    if params[:limit]
      @events = @events.upcoming.limit(params[:limit])
    end

    return @events
  end

end