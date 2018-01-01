module Todo
  class << self
    def client
      return client_from_username unless File.exists?(USER_CONFIG_PATH)

      user_profile = YAML.load_file(USER_CONFIG_PATH)

      @client = Todoable::Client.new(
        token: user_profile[:token],
        expires_at: user_profile[:expires_at]
      )
      @client.authenticate!

      @client
    rescue Todoable::Unauthorized
      client_from_username
    end

    def client_from_username
      username = question("Enter username: ")
      password = question("Enter password: ", noecho: true)

      @client = Todoable::Client.new(
        username: username,
        password: password,
      )
      token, expires_at = @client.authenticate!

      save_user_config(
        username: username,
        token: token,
        expires_at: expires_at,
      )

      @client
    end

  end
end
