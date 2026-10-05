# RottenPotatoes — CHIP 4.8

A Rails 7.2 movie catalog with create, read, update, delete, and index actions.
Movie records store a title, rating, description, release date, and timestamps.
The home page redirects to `/movies`.

## Run locally

The provided development Dockerfile uses Ruby 3.3.8 and Rails 7.x:

```sh
docker build -t rottenpotatoes .
docker run --rm -it -p 3000:3000 -v "$(pwd)":/app rottenpotatoes
```

Inside the container:

```sh
bundle config set without 'production'
bundle install
bundle exec rails db:prepare
bundle exec rails server -b 0.0.0.0
```

Open `http://localhost:3000`. Stop the server with Ctrl+C.
Development and test use separate SQLite databases; production uses PostgreSQL
through `DATABASE_URL`.

## Verify

```sh
bundle exec rails db:test:prepare
bundle exec rspec
```

The request suite checks the movie forms and all CRUD actions, strong parameters,
HTML escaping, missing-record responses, the deployment health check, and seed
idempotence. The four starter movies are Aladdin, When Harry Met Sally, The Help,
and Raiders of the Lost Ark.

## Deploy and submit

See [DEPLOYMENT.md](DEPLOYMENT.md) for the included Render Blueprint and Heroku
Procfile. **A live public deployment is required.** Upload a URL-only file named
`rottenpotatoes-url.txt` to Gradescope; pushing the code alone is insufficient.

## Original assignment

- [Part 1 — setup](Part-1.md)
- [Part 2 — databases](Part-2.md)
- [Part 3 — routes and CRUD](Part-3.md)
- [Part 4 — deployment](Part-4.md)
- [Part 5 — submission](Part-5.md)
