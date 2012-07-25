require File.expand_path(File.dirname(__FILE__) + '/helper')

describe 'CouchbaseModelLogging' do

  let(:bucket) { ENV["TEST_CML_BUCKET"] || "default" }
  let(:client) { CouchbaseModelLogging::Client.new :bucket => bucket }

  describe 'Client' do
    it { client.url.must_equal "http://localhost:8091/pools/default" }
    it { client.connection_options.must_equal :bucket => "default" }
    it { client.native_client.class.name.must_equal "Couchbase::Bucket" }
  end

  describe 'Logger' do

    let(:prefix) { "test_cml" }

    subject { CouchbaseModelLogging::Logger.new client, prefix }

    it "should add one entry correctly" do
      key = "t1"
      hsh = { :a => 1, :b => 2 }
      subject.delete key

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

    it "should add several entries separately correctly" do
      key = "t2a"
      subject.delete key

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

    it "should add several entries at once correctly" do
      key = "t2b"
      subject.delete key

      subject.set key, [{:a => 1, :b => 2}, {:b => 2, :c => 3}, {:c => 3, :d => 4}]

      subject.key?(key).must_equal true

      ary = subject.all key
      ary.size.must_equal 3
      ary[0].must_equal :a => 1, :b => 2
      ary[1].must_equal :b => 2, :c => 3
      ary[2].must_equal :c => 3, :d => 4
    end

    it "should not max out" do
      key = "t3"
      subject.delete key

      hsh = { }
      (1..2048).each { |x| hsh[x] = "a" * 1024 }

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

    it "should get an empty response when missing" do
      key = "missing_key"
      subject.all(key).must_equal []
    end

    it "should delete keys" do
      key = "deleted"
      subject.add key, :test => 1
      subject.key?(key).must_equal true
      subject.delete key
      subject.key?(key).must_equal false
    end

  end
end
