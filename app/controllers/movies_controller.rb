class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    if !params[:ratings].nil?
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    else
      @ratings_to_show = []
    end
      
    @movies = Movie.with_ratings(@ratings_to_show)
    @ratings_to_show_hashed = @ratings_to_show.to_h { |key| [key, ''] }
    @movies = @movies.order(params[:sort_by])
    
    if params[:sort_by] == "title"
      @title_header = "hilite bg-warning"
    end
    
    if params[:sort_by] == "release_date"
      @release_date_header = "hilite bg-warning"
    end
    
    if params[:sort_by]
      session[:sort_by] = params[:sort_by]
    end
    
    if (params[:ratings].nil? && !session[:ratings].nil?) || (params[:sort_by].nil? && !session[:sort_by].nil?)
      redirect_to movies_path("ratings" => session[:ratings].to_h { |key| [key, ''] }, "sort_by" => session[:sort_by])
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
