require "yaml"

module Todo
  module Cache
    TODO_DIR = File.join(Dir.home, ".todo")
    USER_PROFILE_PATH = File.join(TODO_DIR, "user")
    LISTS_PATH = File.join(TODO_DIR, "lists")

    class << self
      def lists
        verify_todo_dir

        YAML.load_file(LISTS_PATH)
      end

      def save_lists(lists)
        verify_todo_dir

        File.write(LISTS_PATH, lists.to_json)
      end

      def user_profile
        verify_todo_dir

        user_json = File.read(USER_PROFILE_PATH)
        JSON.parse(user_json) if user_json
      rescue StandardError
        nil
      end

      def save_user_profile(username:, token:, expires_at:)
        verify_todo_dir

        user_profile = {
          username: username,
          token: token,
          expires_at: expires_at,
        }

        File.open(USER_PROFILE_PATH, "w") do |f|
          f.write(user_profile.to_json)
        end
      end

      def clear
        FileUtils.rm_rf(TODO_DIR)
      end

      private

      def verify_todo_dir
        Dir.mkdir(TODO_DIR) unless File.exists?(TODO_DIR)
      end
    end
  end
end