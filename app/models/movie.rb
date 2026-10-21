class Movie < ApplicationRecord
  RATINGS = %w[G PG PG-13 R NC-17].freeze
  SORT_COLUMNS = %w[title release_date].freeze

  def self.all_ratings
    RATINGS
  end

  def self.with_ratings(ratings_list)
    return all if ratings_list.nil?

    where("UPPER(rating) IN (?)", ratings_list.map { |rating| rating.to_s.upcase })
  end

  def self.sorted_by(column)
    column = "title" unless SORT_COLUMNS.include?(column)
    # The C/BINARY collations match Ruby's String#<=> ordering for titles.
    if column == "title"
      collation = connection.adapter_name == "PostgreSQL" ? '"C"' : "BINARY"
      order(Arel.sql("title COLLATE #{collation} ASC"), :id)
    else
      order(release_date: :asc, id: :asc)
    end
  end
end
