require "io/console"
require "yaml"
require "todo/version"
require "todo/list"
require "todo/item"
require "todoable/lib/todoable"

module Todo
  class << self
    TODO_DIR = File.join(Dir.home, ".todo")

    def run(args:)
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
        puts help
      end
    rescue Todoable::Unauthorized
      puts "Unauthorized"
      puts
    end

    def verify_todo_dir
      Dir.mkdir(TODO_DIR) unless File.exists?(TODO_DIR)
    end

    def client
      path = File.join(TODO_DIR, "user")
      if File.exists?(path)
        user_profile = YAML.load_file(path)

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
      path = File.join(TODO_DIR, "user")

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

      File.open(path, "w") do |f|
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

      path = [Dir.tmpdir, "lists.json"].join("/")
      File.write(path, lists.to_json)

      lists
    end

    def show_list(id:)
      id = find_list_id(id)
      if id
        list = client.get_list(id: id)
        List.show(list)
      end
    rescue Todoable::NotFound
      puts "List not found."
      puts
    end

    def update_list(id:)
      id = find_list_id(id)
      if id
        name = question("Enter new name for the list: ")

        client.update_list(id: id, name: name)
        show_list(id: id)
      end
    rescue Todoable::NotFound
      puts "List not found."
      puts
    end

    def delete_list(id:)
      id = find_list_id(id)
      if id
        if client.delete_list(id: id)
          puts "List deleted."
        end
      end
    rescue Todoable::NotFound
      puts "List not found."
      puts
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
      begin
        if id.length < 36
          path = [Dir.tmpdir, "lists.json"].join("/")
          lists = JSON.parse(File.read(path))

          matches = lists.map { |l| l["id"] }.select do |list_id|
            list_id.start_with?(id)
          end

          if matches.length >= 2
            puts "The list_id you entered matches too many lists."
            puts "Did you mean one of these?"
            matches.each do |match|
              puts "  #{match}"
            end
            puts

            id = false
          elsif matches.length == 1
            id = matches.first
          end
        end
      end

      id
    end

    def question(string, noecho: false)
      puts string
      result = if noecho
        STDIN.noecho(&:gets).chomp
      else
        STDIN.gets.chomp
      end
      puts

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
