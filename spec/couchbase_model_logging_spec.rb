require 'helper'

describe 'CouchbaseModelLogging' do
  let(:bucket) { ENV["TEST_CML_BUCKET"] || "default" }
  let(:client) { CouchbaseModelLogging::Client.new :bucket => bucket }
  describe 'Client' do
    it { client.url.should == "http://localhost:8091/pools/default/buckets/default" }
    it { client.native_client.class.name.should == "Couchbase::Bucket" }
  end
  describe 'Logger' do
    let(:prefix) { "test_cml" }
    subject { CouchbaseModelLogging::Logger.new client, prefix }
    it "should add one hash correctly" do
      client.flush
      subject.add "t1", :a => 1, :b => 2
      subject.key?("t1").should == true
      res = subject.all "t1"
      puts "res : #{res.inspect}"
      res[:a].should == 1
      res[:b].should == 2
    end
  end
end
