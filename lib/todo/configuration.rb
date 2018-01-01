module Todo
  TODO_DIR = File.join(Dir.home, ".todo")
  USER_CONFIG_PATH = File.join(TODO_DIR, "user")
  LISTS_PATH = File.join(TODO_DIR, "lists")

  class << self
    def verify_todo_dir
      Dir.mkdir(TODO_DIR) unless File.exists?(TODO_DIR)
    end

    def save_user_config(username:, token:, expires_at:)
      user_profile = {
        username: username,
        token: token,
        expires_at: expires_at,
      }

      File.open(USER_CONFIG_PATH, "w") do |f|
        f.write(user_profile.to_yaml)
      end
    end

  end
end
