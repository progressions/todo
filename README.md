# Todo

Todo is a command-line tool made as a proof-of-concept for the 'todoable' gem.

## Installation

Install it yourself as:

    $ gem install todo

## Authentication

The command-line tool will ask for username and password, then it will
store the username and your authentication token. When the token
expires, you will be prompted to log in again.

## Usage

    usage: todo <command> [<args>]

        create <name>           Create a new todo list
        item <list_id> <name>   Create an item for a specific list
        delete <list_id>        Delete a list
        help                    Show usage information
        list <list_id>          Show a specific list
        lists                   Show all todo lists
        update <list_id>        Update the name of a list

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/todo.
