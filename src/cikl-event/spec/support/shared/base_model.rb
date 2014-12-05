shared_examples_for 'a Cikl::BaseModel' do
  let(:object) { described_class.new }
  describe "#to_serializable_hash" do
    let(:data) { object.to_serializable_hash }
    it "generates a Hash object" do
      expect(data).to be_a(Hash)
    end
  end
end
