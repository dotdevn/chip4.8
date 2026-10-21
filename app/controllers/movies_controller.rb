class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings
    # A submitted form with no checked boxes means all ratings, whereas a plain
    # visit to /movies restores this browser's previous choices.
    if params.key?(:ratings) || params[:filter_submitted] == "1" || params[:commit] == "Refresh"
      requested_ratings = params[:ratings]
      selected_ratings = requested_ratings.is_a?(ActionController::Parameters) ? requested_ratings.keys.map(&:upcase) : []
    else
      selected_ratings = Array(session[:ratings])
    end
    @ratings_to_show = @all_ratings & selected_ratings
    @ratings_to_show = @all_ratings if @ratings_to_show.empty?
    requested_sort = params.key?(:sort_by) ? params[:sort_by] : session[:sort_by]
    @sort_by = Movie::SORT_COLUMNS.include?(requested_sort) ? requested_sort : "title"
    session[:ratings] = @ratings_to_show
    session[:sort_by] = @sort_by
    @ratings_for_links = @ratings_to_show.index_with { "1" }
    @movies = Movie.with_ratings(@ratings_to_show).sorted_by(@sort_by)
  end

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @movie.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @movie.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, notice: "Movie was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
