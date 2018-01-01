require "spec_helper"
require "fileutils"

RSpec.describe Todo do
  before(:each) do
    stub_const("Todo::TODO_DIR", File.expand_path(".todo", "spec"))
    stub_const("Todo::USER_CONFIG_PATH", File.expand_path(".todo/user", "spec"))
    stub_const("Todo::LISTS_PATH", File.expand_path(".todo/lists", "spec"))
  end

  before(:all) do
    FileUtils.rm_r(File.expand_path(".todo", "spec"))
  end

  after(:all) do
    FileUtils.rm_r(File.expand_path(".todo", "spec"))
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
    let(:lists_attributes) do
      [
        {"name" => "Christmas List", "src" => "http://todoable.teachable.tech/api/lists/123-abc", "id" => "123-abc"},
        {"name" => "Birthday List", "src" => "http://todoable.teachable.tech/api/lists/456-def", "id" => "456-def"}
      ]
    end

    let(:mock_client) { double("mock client", token: "abcdef", expires_at: DateTime.parse("2081-01-01"), lists: lists_attributes) }

    it "gets username and password" do
      expect($stdin).to receive(:gets).and_return("username", "password")
      expect(Todoable::Client).to receive(:new).with({:username=>"username", :password=>"password"}).and_return(mock_client)
      Todo.run(args: ["lists"])
    end
  end
end
