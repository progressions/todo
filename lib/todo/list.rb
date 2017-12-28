module Todo
  module List
    class << self
      def show_all(lists)
        tab = 42
        puts "-"*80

        lists.each do |list|
          offset = tab - list["name"].length
          puts "#{list['name']} #{'.'*offset} #{list['id']}"
        end
      end

      def show(list)
        puts "#{list['name']} (#{list['id']})"
        puts
        Item.show_all(list['items']) if list['items']
      end
    end
  end
end
