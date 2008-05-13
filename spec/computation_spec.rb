require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Computations' do
  describe SimilarityEngine::Coefficients::Tanimoto do
    attr_reader :coefficient
    before(:each) do
      @coefficient = SimilarityEngine::Coefficients::Tanimoto.new
    end
    it "should derive from Computation" do
      coefficient.should be_kind_of(SimilarityEngine::Computation)
    end 
    it "should return 1 on maximum coherence" do
      coefficient.call([1,2,3], [1,2,3]).should == 1
    end
    it "should return 0 on minimum coherence" do
      coefficient.call([1,2,3], [4,5,6]).should == 0
    end 
    it "should not be disturbed by dupes" do
      coefficient.call([1,2], [1]*10 + [2]*10).should == 1
    end 
    it "should return intermediate values" do
      coefficient.call([1,2], [2,3]).should be_close(0.3, 0.1)
    end 
    it "should return 0 when the sets are empty" do
      coefficient.call([], []).should == 0
    end 
  end
end