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
  
  describe SimilarityEngine::Coefficients::Pearson do
    attr_reader :coefficient
    before(:each) do
      @coefficient = SimilarityEngine::Coefficients::Pearson.new
    end
    
    it "should derive from Computation" do
      coefficient.should be_kind_of(SimilarityEngine::Computation)
    end
    
  
    it "should return 0 on maximum coherence with different word ordering" do
      coefficient.call('def abc', 'abc def').should == 0
    end
    
    it "should return -1 on contravariance" do
      coefficient.call('def abc abc', 'abc def def').should == -1
    end
    
    it "should return an intemediate value on longer example" do
      coefficient.call('hello world hello how are you do', 'hello hello gaga how do you do').should be_close( 0.577350269189626, 0.001)
    end
    
    
    it "should return 0 on minimum coherence" do
      coefficient.call('abc def', 'wxy rst').should == 0
    end
    
    it "should return 0 for empty strings" do
      coefficient.call('', 'abc').should == 0
      coefficient.call('abc', '').should == 0
      coefficient.call(nil, 'abc').should == 0
      coefficient.call('abc', nil).should == 0
    end
    
    it "should ignore non-word characters" do
      coefficient.call('a.b.c', 'a b c').should == 0
    end
    
    describe "#filter_words" do
      it "should return an array" do
        @coefficient.filter_words('').should be_instance_of(Array)
      end
      
      it "should return an array of words" do
        @coefficient.filter_words('abc def').should == ['abc', 'def']
      end
      it "should return an array of words with punctuation" do
        @coefficient.filter_words('abc.def').should == ['abc', 'def']
      end
  end
    
  end
end

