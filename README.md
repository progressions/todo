# Todo

Todo is a command-line tool made as a proof-of-concept for the 'todoable' gem.

https://github.com/progressions/todoable

The Todoable gem is a coding sample for Teachable.

## Installation

Install it yourself as:

    $ gem install todo

## Authentication

The command-line tool will ask for username and password, then it will
store the username and your authentication token (but not the password).
When the token expires, you will be prompted to log in again.

## Usage

Invoke the command-line tool with no arguments, or with "help" to see usage
details.

    usage: todo <command> [<args>]

        create <name>               Create a new todo list
        item <list_id> <name>       Create an item for a specific list
        delete <list_id>            Delete a list
        help                        Show usage information
        list <list_id>              Show a specific list
        lists                       Show all todo lists
        update <list_id> <name>     Update the name of a list

### Creating a list

To create a list, pass a string as the name of the list.

    $  todo create "Shopping List"
    Shopping List (f92a96b9-18c0-4ae3-9179-7a3f40698925)

### Showing all lists

    $ todo lists
    name                                        id
    --------------------------------------------------------------------------------
    Shopping List ............................. af0a0005-cfd8-4a81-8dbe-392a2d7a7075
    Birthday List ............................. 46e0c896-a3dd-4cdd-a396-da8befce2b96
    Groceries ................................. 1a7d2d0c-9761-4c69-b39c-6aff62cfdcdb

### Showing a single list

    $ todo list d8443c22-5833-479d-bc5a-9866fe1fc264
    Birthday List (d8443c22-5833-479d-bc5a-9866fe1fc264)

    Unfinished Items

    name                                        id
    --------------------------------------------------------------------------------
    A new cat ................................. 01b44cea-6958-4194-a857-4f89b20e3892
    A new car ................................. 767a4311-8932-41b5-869c-4faa4b95e54e

    Finished Items

    name                                        id
    --------------------------------------------------------------------------------
    A sweater ................................. abcc8b46-a3e3-4a85-a6ac-1741bef39b66
    gum ....................................... 51cc01ae-1701-440d-b3b9-2c3f66415cc6


### Showing a single list from a shortened ID

You can enter only the first few characters of an ID, and the system will attempt
to match it against the full ID of an existing list:

    $ todo list d84
    Birthday List (d8443c22-5833-479d-bc5a-9866fe1fc264)

    Unfinished Items

    name                                        id
    --------------------------------------------------------------------------------
    A new cat ................................. 01b44cea-6958-4194-a857-4f89b20e3892
    A new car ................................. 767a4311-8932-41b5-869c-4faa4b95e54e

    Finished Items

    name                                        id
    --------------------------------------------------------------------------------
    A sweater ................................. abcc8b46-a3e3-4a85-a6ac-1741bef39b66
    gum ....................................... 51cc01ae-1701-440d-b3b9-2c3f66415cc6


If more than one ID matches the shortened ID, you'll be given a warning and
asked to clarify:

    $ todo list 98d
    The list_id you entered matches too many lists.
    Did you mean one of these?
      98d2510c-0eb7-4316-bfef-d38c762b1ffb
      98da6c1b-5cc6-4730-83b0-4e9aa84967a5


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
