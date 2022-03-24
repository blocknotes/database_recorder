# Development

## Tests

```sh
# Re create the recordings
rm -rf spec/dbr
bin/rspec spec/requests
# Check if the recordings match with the expected ones
bin/rspec spec/integration
```
