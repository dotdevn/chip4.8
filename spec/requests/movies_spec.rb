require "rails_helper"

RSpec.describe "RottenPotatoes movies", type: :request do
  let(:attributes) do
    { title: "A Test Movie", rating: "PG", description: "An original description",
      release_date: "2026-10-05" }
  end
  let(:movie) { Movie.create!(attributes) }

  it "redirects the home page to the movie catalog" do
    get root_path
    expect(response).to redirect_to(movies_path)
  end

  it "lists saved movies and offers the new-movie form" do
    movie
    get movies_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("A Test Movie", "New movie")
  end

  it "provides fields for all four movie attributes" do
    get new_movie_path
    expect(response).to have_http_status(:ok)
    %w[title rating description release_date].each do |field|
      expect(response.body).to include("name=\"movie[#{field}]\"")
    end
  end

  it "creates a movie, saves all its attributes, and redirects to its details" do
    expect { post movies_path, params: { movie: attributes } }.to change(Movie, :count).by(1)
    saved = Movie.last
    expect(response).to redirect_to(movie_path(saved))
    expect(saved).to have_attributes(title: "A Test Movie", rating: "PG",
                                    description: "An original description")
    expect(saved.release_date.to_date).to eq(Date.new(2026, 10, 5))
    follow_redirect!
    expect(response.body).to include("Movie was successfully created.")
  end

  it "does not accept an injected database ID when creating a movie" do
    post movies_path, params: { movie: attributes.merge(id: 999_999) }
    expect(response).to have_http_status(:found)
    expect(Movie.last.id).not_to eq(999_999)
  end

  it "shows movie details and escapes HTML in the description" do
    movie.update!(description: "<script>alert('movie')</script>")
    get movie_path(movie)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("A Test Movie", "PG", "2026-10-05", "&lt;script&gt;")
    expect(response.body).not_to include("<script>alert('movie')</script>")
  end

  it "renders the edit form with the existing title" do
    get edit_movie_path(movie)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Editing movie", "value=\"A Test Movie\"")
  end

  it "updates every editable attribute and redirects to the saved movie" do
    patch movie_path(movie), params: {
      movie: { title: "Revised Movie", rating: "R", description: "Revised description",
               release_date: "2004-02-08" }
    }
    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(movie_path(movie))
    expect(movie.reload).to have_attributes(title: "Revised Movie", rating: "R",
                                           description: "Revised description")
    expect(movie.release_date.to_date).to eq(Date.new(2004, 2, 8))
  end

  it "deletes a movie and returns to the catalog" do
    movie
    expect { delete movie_path(movie) }.to change(Movie, :count).by(-1)
    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(movies_path)
    follow_redirect!
    expect(response.body).to include("Movie was successfully destroyed.")
    expect(response.body).not_to include("A Test Movie")
  end

  it "returns 404 for a movie that does not exist" do
    get movie_path(999_999)
    expect(response).to have_http_status(:not_found)
  end

  it "serves the deployment health check" do
    get "/up"
    expect(response).to have_http_status(:ok)
  end

  it "seeds the four assigned movies without duplicating or overwriting them" do
    Rails.application.load_seed
    expect(Movie.count).to eq(4)
    expect(Movie.pluck(:title)).to contain_exactly(
      "Aladdin", "When Harry Met Sally", "The Help", "Raiders of the Lost Ark"
    )
    aladdin = Movie.find_by!(title: "Aladdin")
    expect(aladdin.release_date.to_date).to eq(Date.new(1992, 11, 25))
    aladdin.update!(description: "A user edit")
    Rails.application.load_seed
    expect(Movie.count).to eq(4)
    expect(aladdin.reload.description).to eq("A user edit")
  end
end
