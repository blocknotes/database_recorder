# Database Recorder

Record database queries for testing and development purposes only.
Support for PostgreSQL + RSpec at the moment, storing logs data on files or Redis.

> This project is in Alpha stage, so not fully reliable and major changes could happen

Main features:
- store the history of the queries of a code block when it run (for manual monitoring);
- optionally check if the current queries match the recorded ones (to prevent regressions);
- [EXPERIMENTAL] optionally replay the recorded queries replacing the original requests.

The last feature is not stable yet, consider that it supports only deterministic specs (so it doesn't work with Faker, random data or random order specs).

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

# To store the queries: :file | :redis
DatabaseRecorder::Config.storage = :redis
```

## Do you like it? Star it!

If you use this component just star it. A developer is more motivated to improve a project when there is some interest.

Or consider offering me a coffee, it's a small thing but it is greatly appreciated: [about me](https://www.blocknot.es/about-me).

## Contributors

- [Mattia Roccoberton](https://blocknot.es): author

## License

The gem is available as open-source under the terms of the [MIT](MIT-LICENSE).
