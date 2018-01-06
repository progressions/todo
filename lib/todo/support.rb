module Todo
  class << self
    def with_item(list_id:, id:)
      list_id = find_list_id(list_id)
      if list_id
        list = client.get_list(id: list_id)
        items = list["items"]

        id = find_matching_ids(list["items"], id)

        if id
          yield(list_id, id)
        else
          $stdout.puts "Item not found."
          $stdout.puts
        end
      else
        $stdout.puts "List not found."
        $stdout.puts
      end
    end

    def find_list_id(id)
      lists = cache.lists || get_all_lists

      find_matching_ids(lists, id)
    end

    def find_matching_ids(entries, id)
      return nil unless id
      return id unless id.length < 36

      matches = Array(entries).map { |entry| entry["id"] }.select do |entry_id|
        entry_id.start_with?(id)
      end

      if matches.length >= 2
        $stdout.puts "The ID you entered matches too many IDs."
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

          create <name>                     Create a new todo list
          item <list_id> <name>             Create an item for a specific list
          delete item <list_id> <item_id>   Delete an item
          delete list <list_id>             Delete a list
          finish <list_id> <item_id>        Finish an item from a list
          help                              Show usage information
          list <list_id>                    Show a specific list
          lists                             Show all todo lists
          update <list_id>                  Update the name of a list

      END
    end
  end
end
