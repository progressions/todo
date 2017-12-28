module Todo
  module Item
    class << self
      def show_all(items)
        tab = 42
        puts "-"*80

        items.each do |item|
          offset = tab - item["name"].length
          puts "#{item['name']} #{'.'*offset} #{item['id']}"
        end
      end

      def show(item)
        puts item.inspect
      end
    end
  end
end
