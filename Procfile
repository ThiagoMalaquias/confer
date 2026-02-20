web: bin/rails server -p ${PORT:-5000} -e $RAILS_ENV
release: rake db:migrate
worker: bundle exec sidekiq -C config/sidekiq.yml