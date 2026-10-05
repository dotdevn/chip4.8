# Deploying CHIP 4.8

The assignment requires a working public app. Pushing this repository alone does not complete the submission. Part 4 permits either Heroku or Render.

## Render

This repository includes a Blueprint (`render.yaml`) defining a Ruby web service and a PostgreSQL database on the Free plans.

1. Sign in to [Render](https://dashboard.render.com).
2. Give Render access to the private GitHub repository `dotdevn/chip4.8`.
3. Choose **New → Blueprint** and select this repository, branch `main`.
4. Review the web service and database, confirm their plans are **Free**, and deploy the Blueprint.
5. Wait for the web service to become live, then open its actual public URL. The root redirects to `/movies`; the catalog should contain the four seed movies.
6. Create a movie, open its details, edit it, and delete it to verify the deployed database and forms work.

The Blueprint automatically supplies `DATABASE_URL` and a generated `SECRET_KEY_BASE`. It does not require sharing `config/master.key`. The build installs gems, precompiles assets, applies migrations, and seeds the database. Seeds can be rerun without duplicating the starter movies or overwriting edits to their other fields.

Render's Free PostgreSQL database expires after 30 days, and its Free web service sleeps after 15 minutes without traffic. Allow time for a sleeping service to start before checking the URL. See [Render's Free plan documentation](https://render.com/docs/free).

## Heroku alternative

From a clone of this repository with the Heroku CLI installed and signed in:

```sh
heroku create
heroku addons:create heroku-postgresql
git push heroku main
heroku open
```

Review the database plan and cost before provisioning it. The Procfile's release command automatically migrates and seeds PostgreSQL before the web process starts. For troubleshooting, use `heroku logs --tail` or `heroku run rails db:migrate`.

## Gradescope submission

Once the public app works, create a text file named **`rottenpotatoes-url.txt`** containing only its actual public URL, then upload that file to Gradescope for CHIP 4.8. Do not submit the GitHub repository URL or a localhost URL. The filename stays the same when using Render.

For example, set `app_url` to the actual deployed URL, then run:

```sh
printf '%s\n' "$app_url" > rottenpotatoes-url.txt
```

This file is ignored by Git, as the assignment says it does not need to be committed. No URL file is included before the app has actually been deployed.

## Deployment references

- [Rails 6/7 on Render](https://render.com/docs/deploy-rails-6-7)
- [Rails 7 on Heroku](https://devcenter.heroku.com/articles/getting-started-with-rails7)
- [Assignment Part 5: submission](Part-5.md)
