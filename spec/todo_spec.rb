require "spec_helper"

RSpec.describe Todo do
  before(:each) do
  end

  it "has a version number" do
    expect(Todo::VERSION).not_to be nil
  end

  describe ".run" do
    it "outputs help" do
      expect($stdout).to receive(:puts).with(Todo.help)
      Todo.run
    end
  end
end
