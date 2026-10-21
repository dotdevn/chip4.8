require "rails_helper"
require "nokogiri"

RSpec.describe "Movie sorting and rating preferences", type: :request do
  before do
    Movie.delete_all
    Movie.create!(title: "Zebra", rating: "G", release_date: "1980-01-01")
    Movie.create!(title: "!First", rating: "PG", release_date: "2000-01-01")
    Movie.create!(title: "Alpha", rating: "R", release_date: "1990-01-01")
    Movie.create!(title: "lowercase", rating: "pg", release_date: "1970-01-01")
  end

  def page
    Nokogiri::HTML(response.body)
  end

  def titles
    page.css("#movies tbody tr td:first-child").map(&:text)
  end

  def checked_ratings
    page.css("#ratings_form input[type=checkbox][checked]").map { |input| input["id"].delete_prefix("ratings_") }
  end

  it "shows every rating and sorts titles in Ruby string order on first visit" do
    get movies_path
    expect(response).to have_http_status(:ok)
    expect(titles).to eq(["!First", "Alpha", "Zebra", "lowercase"])
    expect(checked_ratings).to eq(Movie.all_ratings)
    expect(page.at_css("form#ratings_form[method=get] #sort_by")).to be_present
    expect(page.at_css("form#ratings_form #ratings_submit[value=Refresh]")).to be_present
  end

  it "filters case-insensitively while sorting release dates earliest first" do
    get movies_path, params: { ratings: { "PG" => "1" }, sort_by: "release_date" }
    expect(titles).to eq(["lowercase", "!First"])
    expect(checked_ratings).to eq(["PG"])
    expect(page.at_css("#sort_by option[selected]")["value"]).to eq("release_date")
  end

  it "remembers preferences after viewing movie details and returning to the list" do
    get movies_path, params: { ratings: { "G" => "1", "R" => "1" }, sort_by: "release_date" }
    get movie_path(Movie.find_by!(title: "Zebra"))
    get movies_path
    expect(titles).to eq(["Zebra", "Alpha"])
    expect(checked_ratings).to eq(%w[G R])
    expect(page.at_css("#sort_by option[selected]")["value"]).to eq("release_date")
  end

  it "shows all movies and rechecks all boxes when a form submits no ratings" do
    get movies_path, params: { ratings: { "R" => "1" }, sort_by: "release_date" }
    get movies_path, params: { filter_submitted: "1", sort_by: "release_date", commit: "Refresh" }
    expect(titles).to eq(["lowercase", "Zebra", "Alpha", "!First"])
    expect(checked_ratings).to eq(Movie.all_ratings)
  end

  it "lets explicit new preferences replace saved choices" do
    get movies_path, params: { ratings: { "G" => "1" }, sort_by: "release_date" }
    get movies_path, params: { ratings: { "R" => "1" }, sort_by: "title" }
    get movies_path
    expect(titles).to eq(["Alpha"])
    expect(checked_ratings).to eq(["R"])
    expect(page.at_css("#sort_by option[selected]")["value"]).to eq("title")
  end

  it "keeps submitted ratings in column links" do
    get movies_path, params: { ratings: { "G" => "1", "R" => "1" } }
    get page.at_css("#release_date_header")["href"]
    expect(titles).to eq(["Zebra", "Alpha"])
    expect(checked_ratings).to eq(%w[G R])
  end

  it "keeps one visitor's choices separate from another visitor's session" do
    get movies_path, params: { ratings: { "R" => "1" }, sort_by: "release_date" }
    other_visitor = ActionDispatch::Integration::Session.new(Rails.application)
    other_visitor.get movies_path
    other_page = Nokogiri::HTML(other_visitor.response.body)
    expect(other_page.css("#movies tbody tr").length).to eq(4)
    expect(other_page.css("#ratings_form input[checked]").length).to eq(Movie.all_ratings.length)
  end

  it "safely defaults invalid filters and sort columns" do
    get movies_path, params: { ratings: "invalid", sort_by: "title; DROP TABLE movies" }
    expect(response).to have_http_status(:ok)
    expect(titles).to eq(["!First", "Alpha", "Zebra", "lowercase"])
    expect(Movie.count).to eq(4)
  end
end
