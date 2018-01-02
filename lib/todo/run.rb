module Todo
  class << self
    def run(args: {})
      verify_todo_dir

      case args[0]
      when "create"
        create_list(name: args[1])
      when "delete"
        delete(args)
      when "finish"
        finish_item(list_id: args[1], id: args[2])
      when "item"
        create_item(list_id: args[1], name: args[2])
      when "list"
        show_list(id: args[1])
      when "lists"
        all_lists
      when "update"
        update_list(id: args[1], name: args[2])
      else
        $stdout.puts help
      end
    rescue Todoable::Unauthorized
      $stdout.puts "Unauthorized"
      $stdout.puts
    end
  end
end
