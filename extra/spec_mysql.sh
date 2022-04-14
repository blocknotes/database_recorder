#!/bin/bash

export DB_ADAPTER=mysql2
export DB_NAME=database_recorder-test
export DB_HOST=localhost
export DB_USERNAME=root
export DB_PASSWORD=
export RAILS_ENV=test

echo '> Setup DB'
cd spec/dummy && bundle exec rails db:drop db:create db:migrate && cd ../..

echo '> Run specs'
bundle exec rspec

echo '> done.'
