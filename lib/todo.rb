require "io/console"
require "yaml"
require "todo/version"
require "todo/list"
require "todo/item"
require "todoable/lib/todoable"

module Todo
  TODO_DIR = File.join(Dir.home, ".todo")
  USER_CONFIG_PATH = File.join(TODO_DIR, "user")
  LISTS_PATH = File.join(TODO_DIR, "lists")

  class << self
    def run(args: {})
      verify_todo_dir

      case args[0]
      when "list"
        show_list(id: args[1])
      when "update"
        update_list(id: args[1])
      when "delete"
        delete_list(id: args[1])
      when "lists"
        all_lists
      when "create"
        create_list(name: args[1])
      when "item"
        create_item(list_id: args[1], name: args[2])
      else
        $stdout.puts help
      end
    rescue Todoable::Unauthorized
      $stdout.puts "Unauthorized"
      $stdout.puts
    end

    def verify_todo_dir
      Dir.mkdir(TODO_DIR) unless File.exists?(TODO_DIR)
    end

    def client
      if File.exists?(USER_CONFIG_PATH)
        user_profile = YAML.load_file(USER_CONFIG_PATH)

        @client = Todoable::Client.new(
          token: user_profile[:token],
          expires_at: user_profile[:expires_at]
        )
      else
        client_from_username
      end
    rescue Todoable::Unauthorized
      client_from_username
    end

    def client_from_username
      username = question("Enter username: ")
      password = question("Enter password: ", noecho: true)

      @client = Todoable::Client.new(
        username: username,
        password: password,
      )

      user_profile = {
        username: username,
        token: @client.token,
        expires_at: @client.expires_at,
      }

      File.open(USER_CONFIG_PATH, "w") do |f|
        f.write(user_profile.to_yaml)
      end

      @client
    end

    def all_lists
      lists = get_all_lists
      List.show_all(lists)
    end

    def get_all_lists
      lists = client.lists

      File.write(LISTS_PATH, lists.to_yaml)

      lists
    end

    def show_list(id:)
      id = find_list_id(id)
      if id
        list = client.get_list(id: id)
        List.show(list)
      end
    rescue Todoable::NotFound
      $stdout.puts "List not found."
      $stdout.puts
    end

    def update_list(id:)
      id = find_list_id(id)
      if id
        name = question("Enter new name for the list: ")

        client.update_list(id: id, name: name)
        show_list(id: id)
      end
    rescue Todoable::NotFound
      $stdout.puts "List not found."
      $stdout.puts
    end

    def delete_list(id:)
      id = find_list_id(id)
      if id
        if client.delete_list(id: id)
          $stdout.puts "List deleted."
        end
      end
    rescue Todoable::NotFound
      $stdout.puts "List not found."
      $stdout.puts
    end

    def create_list(name:)
      list = client.create_list(name: name)
      List.show(list)
      get_all_lists
    end

    def create_item(list_id:, name:)
      list_id = find_list_id(list_id)
      if list_id
        item = client.create_item(list_id: list_id, name: name)

        show_list(id: list_id)
      end
    end

    def find_list_id(id)
      return id unless File.exists?(LISTS_PATH)
      return id unless id.length < 36

      lists = YAML.load_file(LISTS_PATH)

      matches = lists.map { |list| list["id"] }.select do |list_id|
        list_id.start_with?(id)
      end

      if matches.length >= 2
        $stdout.puts "The list_id you entered matches too many lists."
        $stdout.puts "Did you mean one of these?"
        matches.each do |match|
          $stdout.puts "  #{match}"
        end
        $stdout.puts

        id = false
      elsif matches.length == 1
        id = matches.first
      end

      id
    end

    def question(string, noecho: false)
      $stdout.puts string
      result = if noecho
        $stdin.noecho(&:gets).chomp
      else
        $stdin.gets.chomp
      end
      $stdout.puts

      result
    end

    def help
      <<~END
      usage: todo <command> [<args>]

          create <name>           Create a new todo list
          item <list_id> <name>   Create an item for a specific list
          delete <list_id>        Delete a list
          help                    Show usage information
          list <list_id>          Show a specific list
          lists                   Show all todo lists
          update <list_id>        Update the name of a list

      END
    end
  end
end
