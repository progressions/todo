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
        update_list(id: args[1], name: args[2])
      when "delete"
        delete_list(id: args[1])
      when "lists"
        all_lists
      when "create"
        create_list(name: args[1])
      when "item"
        create_item(list_id: args[1], name: args[2])
      when "finish"
        finish_item(list_id: args[1], id: args[2])
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
      return client_from_username unless File.exists?(USER_CONFIG_PATH)

      user_profile = YAML.load_file(USER_CONFIG_PATH)

      @client = Todoable::Client.new(
        token: user_profile[:token],
        expires_at: user_profile[:expires_at]
      )
      @client.authenticate!

      @client
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
      token, expires_at = @client.authenticate!

      save_user_config(
        username: username,
        token: token,
        expires_at: expires_at,
      )

      @client
    end

    def save_user_config(username:, token:, expires_at:)
      user_profile = {
        username: username,
        token: token,
        expires_at: expires_at,
      }

      File.open(USER_CONFIG_PATH, "w") do |f|
        f.write(user_profile.to_yaml)
      end
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

    def update_list(id:, name:)
      id = find_list_id(id)
      if id
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
          $stdout.puts
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

        $stdout.puts "Item created.\n"

        show_list(id: list_id)
      end
    end

    def finish_item(list_id:, id:)
      list_id = find_list_id(list_id)
      if list_id
        list = client.get_list(id: list_id)
        items = list["items"]

        id = find_item_id(list["items"], id)

        if id
          item = items.find { |i| i["id"] == id }
          if item["finished_at"]
            $stdout.puts "Item already finished."
            $stdout.puts
          else
            client.finish_item(list_id: list_id, id: id)

            $stdout.puts "Item finished."
            $stdout.puts

            show_list(id: list_id)
          end
        else
          $stdout.puts "Item not found."
          $stdout.puts
        end
      else
        $stdout.puts "List not found."
        $stdout.puts
      end
    end

    def find_item_id(items, id)
      return nil unless id
      return id unless id.length < 36

      matches = items.map { |item| item["id"] }.select do |item_id|
        item_id.start_with?(id)
      end

      if matches.length >= 2
        $stdout.puts "The item ID you entered matches too many items."
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

          create <name>                 Create a new todo list
          item <list_id> <name>         Create an item for a specific list
          delete <list_id>              Delete a list
          finish <list_id> <item_id>    Finish an item from a list
          help                          Show usage information
          list <list_id>                Show a specific list
          lists                         Show all todo lists
          update <list_id>              Update the name of a list

      END
    end
  end
end
