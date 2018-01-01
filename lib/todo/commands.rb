module Todo
  class << self
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

    def delete(args)
      case args[1]
      when "list"
        delete_list(id: args[2])
      when "item"
        delete_item(list_id: args[2], id: args[3])
      end
    end

    def delete_list(id:)
      id = find_list_id(id)
      if client.delete_list(id: id)
        $stdout.puts "List deleted."
        $stdout.puts
      end
    rescue Todoable::NotFound
      $stdout.puts "List not found."
      $stdout.puts
    end

    def delete_item(list_id:, id:)
      with_item(list_id: list_id, id: id) do |list_id, id|
        client.delete_item(list_id: list_id, id: id)

        $stdout.puts "Item deleted."
        $stdout.puts

        show_list(id: list_id)
      end
    end

    def finish_item(list_id:, id:)
      with_item(list_id: list_id, id: id) do |list_id, id|
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
      end
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
  end
end
