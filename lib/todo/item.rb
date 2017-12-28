module Todo
  module Item
    class << self
      TAB = 42

      def show_all(items)
        finished_items = items.select { |i| i["finished_at"] }
        unfinished_items = items.reject { |i| i["finished_at"] }

        puts "Unfinished Items"
        puts

        puts "f name #{' '*38} id"
        puts "-"*80

        show_items(unfinished_items)

        puts

        puts "Finished Items"
        puts

        puts "f name #{' '*38} id"
        puts "-"*80

        show_items(finished_items)
      end

      def show_items(items)
        items.each do |item|
          offset = TAB - item["name"].length
          puts "#{item['name']} #{'.'*offset} #{item['id']}"
        end
      end

      def show(item)
        puts item.inspect
      end
    end
  end
end
