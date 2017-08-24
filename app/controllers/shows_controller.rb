class ShowsController < ApplicationController
  before_action :find_show, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @shows = Show.all.order("name ASC")
  end

  def new
    @show = current_user.shows.build
    @show.reviews.build
  end

  def create
    search = Show.find_info_with_tmdb(params[:show][:name])
    @show = current_user.shows.build(show_params.merge(search))
    if @show.save
      redirect_to @show
    else
      render :new, alert: @show.errors.full_messages
    end
  end

  def show
    @show = Show.find_by(id: params[:id])
  	@reviews = Review.where(show_id: @show.id)
  end

  def edit
    @show = Show.find_by(id: params[:id])
  end

  def update
    if @show.update(show_params)
      render :show, notice: 'Show successfully updated'
    else
      render :edit, notice: @show.errors.full_messages
    end
  end

  def destroy
    @show.destroy
    redirect_to shows_url, notice: 'Show successfully deleted'
  end

  private

  def find_show
    @show = Show.find_by(id: params[:id])
  end

  def show_params
    params.require(:show).permit(
      :name,
      :overview,
      :poster,
      :rating,
      :num_episodes,
      :num_seasons,
      :cast,
      :created,
      :network,
      :genres,
      :backdrop,
      reviews_attributes: [:rating, :comment, :user_id]
    )
  end
end
