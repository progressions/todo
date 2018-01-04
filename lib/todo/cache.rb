require "yaml"
require "redis"

module Todo
  class << self
    def cache
      if todorc["redis"]
        Cache::Redis
      else
        Cache::FileSystem
      end
    end

    def todorc
      if File.exists?(config_path)
        YAML.load_file(config_path)
      else
        {}
      end
    end

    private

    def config_path
      File.join(Dir.home, ".todorc")
    end
  end

  module Cache
    module Redis
      class << self
        def lists
          JSON.parse(redis.get("lists"))
        rescue StandardError
          nil
        end

        def save_lists(lists)
          redis.set("lists", lists.to_json, ex: 600)
        end

        def user_profile
          user_json = redis.get("user")
          JSON.parse(user_json)
        rescue StandardError
          nil
        end

        def save_user_profile(username:, token:, expires_at:)
          user_profile = {
            username: username,
            token: token,
            expires_at: expires_at,
          }

          redis.set("user", user_profile.to_json, ex: 1_200)
        end

        def clear
          redis.pipelined do
            redis.del("user")
            redis.del("lists")
          end
        end

        private

        def redis
          @redis ||= ::Redis.new(redis_config)
        end

        def redis_config
          Todo.todorc["redis"]
        end
      end
    end

    module FileSystem
      class << self
        def lists
          verify_cache

          JSON.parse(File.read(lists_path))
        rescue StandardError
          nil
        end

        def save_lists(lists)
          verify_cache

          File.write(lists_path, lists.to_json)
        end

        def user_profile
          verify_cache

          user_json = File.read(user_profile_path)
          JSON.parse(user_json) if user_json
        rescue StandardError
          nil
        end

        def save_user_profile(username:, token:, expires_at:)
          verify_cache

          user_profile = {
            username: username,
            token: token,
            expires_at: expires_at,
          }

          File.open(user_profile_path, "w") do |f|
            f.write(user_profile.to_json)
          end
        end

        def clear
          FileUtils.rm_rf(todo_dir)
        end

        private

        def verify_cache
          Dir.mkdir(todo_dir) unless File.exists?(todo_dir)
        end

        def todo_dir
          @todo_dir ||= File.join(Dir.home, ".todo")
        end

        def user_profile_path
          File.join(todo_dir, "user")
        end

        def lists_path
          File.join(todo_dir, "lists")
        end
      end
    end
  end
end
