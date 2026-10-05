# Add the assignment's starter movies without duplicating them on later deploys.
movies = [
  { title: "Aladdin", rating: "G", release_date: "25-Nov-1992" },
  { title: "When Harry Met Sally", rating: "R", release_date: "21-Jul-1989" },
  { title: "The Help", rating: "PG-13", release_date: "10-Aug-2011" },
  { title: "Raiders of the Lost Ark", rating: "PG", release_date: "12-Jun-1981" }
]

movies.each do |attributes|
  Movie.find_or_create_by!(title: attributes[:title]) do |movie|
    movie.assign_attributes(attributes)
  end
end
