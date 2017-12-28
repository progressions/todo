require "todo/version"
require "todo/list"
require "todo/item"
require "todoable/lib/todoable"

module Todo
  class << self
    def run
      case ARGV[0]
      when "list"
        show_list(id: ARGV[1])
      when "update"
        update_list(id: ARGV[1])
      when "delete"
        delete_list(id: ARGV[1])
      when "lists"
        all_lists
      when "create"
        create_list
      when "item"
        create_item(list_id: ARGV[1])
      else
        puts help
      end
    end

    def client
      @client ||= Todoable::Client.new(
        username: ENV["TODOABLE_USERNAME"],
        password: ENV["TODOABLE_PASSWORD"]
      )
    end

    def all_lists
      lists = client.lists

      path = [Dir.tmpdir, "lists.json"].join("/")
      File.write(path, lists.to_json)

      List.show_all(lists)
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

    def create_list
      name = question("Enter name for the new list: ")

      list = client.create_list(name: name)
      List.show(list)
    end

    def create_item(list_id:)
      list_id = find_list_id(list_id)
      if list_id

        name = question("Enter name for the new item: ")

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

    def question(string)
      puts string
      result = STDIN.gets.chomp
      puts

      result
    end

    def help
      <<~END
      usage: todo <command> [<args>]

         create             Create a new todo list
         item <list_id>     Create an item for a specific list
         delete <list_id>   Delete a list
         help               Show usage information
         list <list_id>     Show a specific list
         lists              Show all todo lists
         update <list_id>   Update the name of a list

      END
    end
  end
end
