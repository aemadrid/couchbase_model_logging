require File.expand_path(File.dirname(__FILE__) + '/helper')

describe 'CouchbaseModelLogging' do

  let(:bucket) { ENV["TEST_CML_BUCKET"] || "default" }
  let(:client) { CouchbaseModelLogging::Client.new :bucket => bucket }

  describe 'Client' do
    it { client.url.must_equal "http://localhost:8091/pools/default/buckets/#{bucket}" }
    it { client.native_client.class.name.must_equal "Couchbase::Bucket" }
  end

  describe 'Logger' do

    let(:prefix) { "test_cml" }

    subject { CouchbaseModelLogging::Logger.new client, prefix }

    it "should add one entry correctly" do
      key = "t1"
      hsh = { :a => 1, :b => 2 }
      client.delete subject.prefixed_key_for(key)

      subject.add key, hsh
      subject.key?(key).must_equal true

      encoded = subject.get key
      encoded.must_equal subject.encode(hsh)

      decoded = subject.decode encoded
      decoded.must_equal [hsh]

      ary = subject.all key
      ary.size.must_equal 1
      ary[0].must_equal hsh
    end

    it "should add several entries correctly" do
      key = "t2"
      client.delete subject.prefixed_key_for(key)

      subject.add key, :a => 1, :b => 2
      subject.add key, :b => 2, :c => 3
      subject.add key, :c => 3, :d => 4

      subject.key?(key).must_equal true

      ary = subject.all key
      ary.size.must_equal 3
      ary[0].must_equal :a => 1, :b => 2
      ary[1].must_equal :b => 2, :c => 3
      ary[2].must_equal :c => 3, :d => 4
    end

    it "should get an empty response when missing" do
      key = "missing_key"
      subject.all(key).must_equal []
    end

  end
end
