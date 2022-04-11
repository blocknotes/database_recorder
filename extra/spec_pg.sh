#!/bin/bash

export DB_ADAPTER=postgresql
export DB_NAME=database_recorder-test
export DB_HOST=localhost
export DB_USERNAME=postgres
export DB_PASSWORD=postgres
export RAILS_ENV=test

echo '> Setup DB'
cd spec/dummy && bundle exec rails db:drop db:create db:migrate && cd ../..

echo '> Run specs'
bundle exec rspec

echo '> done.'
