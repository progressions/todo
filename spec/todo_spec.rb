require "spec_helper"
require "fileutils"

RSpec.describe Todo do
  let(:lists_attributes) do
    [
      {"name" => "Christmas List", "src" => "http://todoable.teachable.tech/api/lists/123-abc", "id" => "123-abc"},
      {"name" => "Birthday List", "src" => "http://todoable.teachable.tech/api/lists/456-def", "id" => "123-def"}
    ]
  end

  let(:list_attributes) do
    {
      "name" => "Christmas List",
      "src" => "http://todoable.teachable.tech/api/lists/123-abc",
      "id" => "123-abc"
    }
  end

  let(:mock_client) { double("mock client", lists: lists_attributes, get_list: list_attributes, authenticate!: ["abcdef", DateTime.parse("2081-01-01")]) }
  let(:user_config_path) { File.join(todo_dir, "user") }
  let(:lists_path) { File.join(todo_dir, "lists") }

  def todo_dir
    @todo_dir ||= File.expand_path(".todo", "spec")
  end

  before(:each) do
    stub_const("Todo::TODO_DIR", todo_dir)
    stub_const("Todo::USER_CONFIG_PATH", File.join(todo_dir, "user"))
    stub_const("Todo::LISTS_PATH", File.join(todo_dir, "lists"))
    allow(Todoable::Client).to receive(:new).with(token: "abcdef", expires_at: anything).and_return(mock_client)
  end

  before(:all) do
    FileUtils.rm_rf(todo_dir)
  end

  after(:all) do
    FileUtils.rm_rf(todo_dir)
  end

  it "has a version number" do
    expect(Todo::VERSION).not_to be nil
  end

  describe ".run" do
    it "creates .todo directory" do
      Todo.run
      expect(File.exists?(Todo::TODO_DIR)).to be_truthy
    end

    it "outputs help" do
      expect($stdout).to receive(:puts).with(Todo.help)
      Todo.run
    end
  end

  describe ".all_lists" do
    it "gets username and password" do
      expect($stdin).to receive(:gets).and_return("username", "password")
      expect(Todoable::Client).to receive(:new).with({:username=>"username", :password=>"password"}).and_return(mock_client)
      Todo.run(args: ["lists"])
    end

    it "caches token and expires_at" do
      FileUtils.rm(user_config_path)

      allow($stdin).to receive(:gets).and_return("username", "password")
      allow(Todoable::Client).to receive(:new).with({:username=>"username", :password=>"password"}).and_return(mock_client)

      Todo.run(args: ["lists"])

      user_config = YAML.load_file(user_config_path)
      expect(user_config[:username]).to eq("username")
      expect(user_config[:token]).to eq("abcdef")
      expect(user_config[:expires_at].to_s).to eq("2081-01-01T00:00:00+00:00")
    end

    it "uses cached token and expires_at after authentication" do
      expect(Todoable::Client).to receive(:new).with(token: "abcdef", expires_at: anything).and_return(mock_client)
      Todo.run(args: ["lists"])
    end

    context "when authenticated" do
      it "prints lists" do
        expect { Todo.run(args: ["lists"]) }.to output(/Birthday List/).to_stdout
        expect { Todo.run(args: ["lists"]) }.to output(/Christmas List/).to_stdout
      end

      it "caches lists" do
        Todo.run(args: ["lists"])

        lists = YAML.load_file(lists_path)
        expect(lists).to eq(lists_attributes)
      end
    end
  end

  describe ".show_list" do
    it "prints list" do
      expect { Todo.run(args: ["list", "123-abc"]) }.to output("Christmas List (123-abc)\n\n").to_stdout
    end

    context "with matching id" do
      let(:lists_attributes) do
        [
          {"name" => "Christmas List", "src" => "http://todoable.teachable.tech/api/lists/123-abc", "id" => "123-abc"},
          {"name" => "Birthday List", "src" => "http://todoable.teachable.tech/api/lists/456-def", "id" => "123-def"}
        ]
      end

      it "alerts the user if the ID given is too vague" do
        File.open(lists_path, "w") { |f| f.write(lists_attributes.to_yaml) }
        expect { Todo.run(args: ["list", "123"]) }.to output("The list_id you entered matches too many lists.\nDid you mean one of these?\n  123-abc\n  123-def\n\n").to_stdout
      end
    end
  end

  describe ".create_list" do
    it "creates list from arguments" do
      expect(mock_client).to receive(:create_list).with(name: "\"Christmas List\"").and_return(list_attributes)
      expect { Todo.run(args: ["create", "\"Christmas List\""]) }.to output("Christmas List (123-abc)\n\n").to_stdout
    end
  end

  describe ".update_list" do
    let(:list_attributes) do
      {
        "name" => "Shopping List",
        "src" => "http://todoable.teachable.tech/api/lists/123-abc",
        "id" => "123-abc"
      }
    end

    it "creates list from arguments" do
      expect(mock_client).to receive(:update_list).with(id: "123-abc", name: "\"Shopping List\"").and_return(list_attributes)
      expect { Todo.run(args: ["update", "123-abc", "\"Shopping List\""]) }.to output("Shopping List (123-abc)\n\n").to_stdout
    end
  end
end
