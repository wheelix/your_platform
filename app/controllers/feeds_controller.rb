class FeedsController < ApplicationController

  def index
    authorize! :index, :feeds
    set_current_title t :feeds

    @feeds = Blog.all + ActsAsTaggableOn::Tag.all
    @feeds = @feeds.select { |feed| can? :read, feed }
  end

  def show
    @rss_root = current_home_page || Page.root
    @rss_items = case params[:id]
    when 'default'
      authorize! :read, :default_feed
      default_feed
    when 'personal'
      authorize! :read, :personal_feed
      personal_feed
    when 'public'
      authorize! :read, :public_feed
      public_feed
    when 'podcast'
      authorize! :read, :default_feed
      podcast_feed
    end.select { |page| page.not_empty? && can?(:read, page) && page.visible_to?(current_user) }
  end

  private

  def default_feed
    personal_feed || public_feed
  end

  def personal_feed
    current_user.try(:news_pages)
  end

  def public_feed
    BlogPost.all
  end

  def podcast_feed
    default_feed.select { |blog_post| blog_post.video? }
  end

end