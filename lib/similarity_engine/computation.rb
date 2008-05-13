
module SimilarityEngine
  # Base class for all similarity computation classes. This class handles 
  # storage of the two relevant instances in the accessors +a+ and +b+. 
  #
  class Computation
    # Compute similarity coefficient for the objects +a+ and +b+. 
    #
    def coefficient(a, b)
      raise NotImplementedError, "#{self.class}#coefficient(a,b) needs to be implemented"
    end
    
    # Alias for coefficient - you don't need to implement this in subclasses.
    #
    def call(*args); coefficient(*args); end
  end
  
  module Coefficients
    # Tanimoto coefficient is defined on two sets of objects A and B. 
    # Let n be the number of objects in the union of A and B and m be the 
    # number of objects in the intersection of A and B. Tanimoto defines
    # his index as follows: 
    #
    #   Tanimoto(A, B) = 1 - (m / n)
    # 
    # We use a modified version that yields 0 on no similarity and 1 on 
    # maximum similarity - a normalized version, so to speak: 
    #
    #   norm_Tanimoto(A, B) = (m / n)
    #
    require 'set'
    class Tanimoto < Computation
      def coefficient(a, b)
        sa, sb = Set.new(a), Set.new(b)
      
        n = (sa + sb).size
        m = (sa & sb).size
      
        if n > 0
          m / Float(n)
        else 
          0
        end
      end
    end
  end
end