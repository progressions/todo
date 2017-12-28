require "todo/version"
require "todo/list"
require "todo/item"
require "todoable/lib/todoable"

module Todo
  class << self
    def run
      case ARGV[0]
      when "list"
        show_list(ARGV[1])
      when "lists"
        all_lists
      when "create"
        create_list
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
      List.show_all(lists)
    end

    def show_list(id)
      list = client.get_list(id: id)
      List.show(list)
    end

    def create_list
      name = question("Enter name for the new list: ")

      list = client.create_list(name: name)
      List.show(list)
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

         lists          Show all todo lists
         create         Create a new todo list
         list [id]      Show a specific list

      END
    end
  end
end
