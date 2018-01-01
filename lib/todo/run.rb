module Todo
  class << self
    def run(args: {})
      verify_todo_dir

      case args[0]
      when "list"
        show_list(id: args[1])
      when "update"
        update_list(id: args[1], name: args[2])
      when "delete"
        delete(args)
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
  end
end
