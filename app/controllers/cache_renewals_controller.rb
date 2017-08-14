class CacheRenewalsController < ApplicationController

  expose :user, -> { User.find(params[:user_id]) if params[:user_id] }
  expose :group, -> { Group.find(params[:group_id]) if params[:group_id] }
  expose :page, -> { Page.find(params[:page_id]) if params[:page_id] }
  expose :event, -> { Event.find(params[:event_id]) if params[:event_id] }
  expose :object, -> { user || group || page || event }

  def create
    authorize! :read, object
    object.delete_cache
    redirect_to object
  end

end