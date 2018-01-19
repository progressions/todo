module Todo
  class << self
    def run(args: {})
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
      when "logout"
        logout
      when "update"
        update_list(id: args[1], name: args[2])
      else
        $stdout.puts help
      end
    rescue Todoable::Unauthorized
      logout

      $stdout.puts "Could not authenticate."
      $stdout.puts
    rescue Errno::ECONNREFUSED
      $stdout.puts "Could not reach server."

      exit 1
    end
  end
end
