web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -q mailers, 5 -q default -e production -c 1
