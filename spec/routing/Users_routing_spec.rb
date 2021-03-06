require "rails_helper"

RSpec.describe UsersController, :type => :routing do
  describe "routing" do

    it "routes to #terms" do
      expect(:get => "/people").to route_to("people#terms")
    end

    it "routes to #new" do
      expect(:get => "/people/new").to route_to("people#new")
    end

    it "routes to #terms" do
      expect(:get => "/people/1").to route_to("people#terms", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/people/1/edit").to route_to("people#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/people").to route_to("people#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/people/1").to route_to("people#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/people/1").to route_to("people#destroy", :id => "1")
    end

  end
end
