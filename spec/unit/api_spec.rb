require 'spec_helper'

describe Factual::API do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
  end

  it "should be able to get a query" do
    table = Factual::Query::Table.new(@api, "t/places")
    query = table.search("foo")
    @api.get(query)
    @token.last_url.should == "http://api.v3.factual.com/t/places?q=foo"
  end

  it "should be able to get a row" do
    table = Factual::Query::Table.new(@api, "t/places")
    table.row("id123")
    @token.last_url.should == "http://api.v3.factual.com/t/places/id123"
  end

  it "should be able to post a boost" do
    flag_params = {
      :table => "places-us",
      :factual_id => "id123",
      :q => "Coffee",
      :user => "user123" }
    flag = Factual::Write::Boost.new(@api, flag_params)
    @api.post(flag)
    @token.last_url.should == "http://api.v3.factual.com/t/places-us/boost"
    @token.last_body.should == "factual_id=id123&q=Coffee&user=user123"
  end

  it "should be able to post a flag" do
    flag_params = {
      :table => "global",
      :factual_id => "id123",
      :problem => :duplicate,
      :user => "user123" }
    flag = Factual::Write::Flag.new(@api, flag_params)
    @api.post(flag)
    @token.last_url.should == "http://api.v3.factual.com/t/global/id123/flag"
    @token.last_body.should == "problem=duplicate&user=user123"
  end

  it "should be able to get a query with additional params" do
    table = Factual::Query::Table.new(@api, "t/places")
    query = table.search("foo")
    @api.get(query, "bar" => "baz")
    @token.last_url.should == "http://api.v3.factual.com/t/places?q=foo&bar=baz"
  end

  it "should be able to get the schema for a table" do
    table = Factual::Query::Table.new(@api, "t/places")
    @api.schema(table)
    @token.last_url.should == "http://api.v3.factual.com/t/places/schema"
  end

  it "should be able to do a raw read" do
    @api.raw_get("t/foo", :bar => {"not" => "baz"})
    @token.last_url.should == "http://api.v3.factual.com/t/foo?bar=%7B%22not%22%3A%22baz%22%7D"
  end

  it "should be able to do a raw post" do
    @api.raw_post("t/foo", :bar => {"not" => "baz"})
    @token.last_url.should == "http://api.v3.factual.com/t/foo"
    @token.last_body.should == "bar=%7B%22not%22%3A%22baz%22%7D"
  end
end
