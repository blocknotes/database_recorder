# Database Recorder

Record database queries for testing and development purposes only.
Support only RSpec at the moment, storing logs data on files or Redis.

Main features:
- store the history of the queries of a test when it run (for monitoring);
- eventually check if the current queries match the recorded ones (to prevent regressions);
- [EXPERIMENTAL] optionally replay the recorded queries replacing the original requests.

See below for more details.

## Install

- Add to your Gemfile: `gem 'database_recorder'` (:development, :test groups recommended)
- With RSpec:
  + Add to the `spec_helper.rb` (or rails_helper): `DatabaseRecorder::RSpec.setup`
  + In RSpec examples: add `:dbr` metadata
  + To verify the matching with the recorded query use: `dbr: { verify_queries: true }`

```rb
  it 'returns 3 posts', :dbr do
    # ...
  end
```

## Config

Add to your _spec_helper.rb_:

```rb
# To print the queries while executing the specs: false | true | :color
DatabaseRecorder::Config.print_queries = true

# Replay the recordings intercepting the queries
DatabaseRecorder::Config.replay_recordings = true

# To store the queries: :file | :redis | nil
DatabaseRecorder::Config.storage = :redis
# nil to avoid storing the queries
```

## History of the queries

Using the `print_queries` config option is possible to see the executed queries while running the specs. It can be used to identify easily what is going on in a specific example without having to analyze the log files.

Using the `:file` storage, the history is also recorded to files (default path: **spec/dbr**) in YAML format. This is useful for checking what's happening with more details, it includes the query results and some extra data.

## Test queries' changes

This feature can be used to prevent queries regressions.
It requires to have previously stored the history of the queries (which could be versioned if using file storage).
It can be activated using `dbr: { verify_queries: true }` metadata.

To work correctly in requires `prepared_statements: true` option in the **database.yml** config file, in the connection block options (available for both Postgres and MySQL).

## Replay the recorded queries

This feature is not stable (at this stage), so use it carefully and supports only deterministic tests (so it doesn't work with Faker, random data or random order specs) and only Postgres is supported for now.
It requires to have previously stored the history of the queries.
Using this feature can improve the test suite performances (especially using redis storage).
It can be activated using `replay_recordings` config option.

Some workarounds to make it works:
- Run specs with `bin/rspec --order defined`
- Set a specific seed for Faker (optionally with an ENV var): `Faker::Config.random = Random.new(42)`
- Set a specific Ruby seed (optionally with an ENV var): `srand(42)`

## Do you like it? Star it!

If you use this component just star it. A developer is more motivated to improve a project when there is some interest.

Or consider offering me a coffee, it's a small thing but it is greatly appreciated: [about me](https://www.blocknot.es/about-me).

## Contributors

- [Mattia Roccoberton](https://blocknot.es): author

## License

The gem is available as open-source under the terms of the [MIT](MIT-LICENSE).
