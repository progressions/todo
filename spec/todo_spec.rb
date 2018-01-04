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

  before(:each) do
    allow($stdout).to receive(:puts)

    allow($stdin).to receive(:gets).and_return("username", "password")
    allow(Todoable::Client).to receive(:new).with({:username=>"username", :password=>"password"}).and_return(mock_client)
    allow(Todoable::Client).to receive(:new).with(token: "abcdef", expires_at: anything).and_return(mock_client)

    # Set up all the configuration and authentication by running this once
    Todo.client
  end

  describe ".run" do
    it "outputs help with no arguments" do
      expect($stdout).to receive(:puts).with(Todo.help)
      Todo.run
    end

    it "outputs help" do
      expect($stdout).to receive(:puts).with(Todo.help)
      Todo.run(args: ["help"])
    end
  end

  describe ".all_lists" do
    it "gets username and password" do
      Todo.cache.clear

      expect($stdin).to receive(:gets).and_return("username", "password")
      expect(Todoable::Client).to receive(:new).with({:username=>"username", :password=>"password"}).and_return(mock_client)
      Todo.run(args: ["lists"])
    end

    it "caches token and expires_at" do
      Todo.cache.clear

      allow($stdin).to receive(:gets).and_return("username", "password")
      allow(Todoable::Client).to receive(:new).with({:username=>"username", :password=>"password"}).and_return(mock_client)

      Todo.run(args: ["lists"])

      user_profile = Todo.cache.user_profile
      expect(user_profile["username"]).to eq("username")
      expect(user_profile["token"]).to eq("abcdef")
      expect(user_profile["expires_at"].to_s).to eq("2081-01-01T00:00:00+00:00")
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

        lists = Todo.cache.lists
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
        Todo.cache.save_lists(lists_attributes)

        expect { Todo.run(args: ["list", "123"]) }.to output("The ID you entered matches too many IDs.\nDid you mean one of these?\n  123-abc\n  123-def\n\n").to_stdout
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

  describe ".finish_item" do
    it "finishes an item" do
      expect(mock_client).to receive(:finish_item).with(list_id: "123-abc", id: "987-zyx").and_return(true)
      expect { Todo.run(args: ["finish", "123-abc", "987-zyx"]) }.to output("Item finished.\n\nChristmas List (123-abc)\n\n").to_stdout
    end

    it "lets you know if it can't finish it" do
      expect(mock_client).to receive(:finish_item).with(list_id: "123-abc", id: "987-zyx").and_raise(Todoable::NotFound)
      expect { Todo.run(args: ["finish", "123-abc", "987-zyx"]) }.to output("Could not finish item.\n\n").to_stdout
    end
  end
end
