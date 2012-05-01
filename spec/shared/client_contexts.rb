shared_context 'connections' do
  let(:connection_opts) { ['localhost:2181', {:thread => :per_callback}] }

  before do 
    @zk = ZK.new(*connection_opts)
    @base_path = '/zk-group'
    @zk.rm_rf(@base_path)
  end

  after do 
    @zk.close! unless @zk.closed?
    ZK.open(*connection_opts) { |zk| zk.rm_rf(@base_path) }
  end
end
