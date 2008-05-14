
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
    
    # Pearson coefficient for str1 and str2
    #
    class Pearson < Computation
      
      def filter_words(str)
        
        str.downcase.gsub(/\W/, ' ').split
      end
      
      def filter_freqs(hash)
        words = {}
        max = hash.values.max
        hash.each do |word, count|
          words[word] = count if (count > 0.1 * max) && (count < 0.5 * max)
        end
        words
      end
      
      def freq_count(arr)
        arr.inject(Hash.new(0)) { |freqs, word| freqs[word] += 1; freqs }
      end
      
      def pearson(h1, h2)
        uniq_words = h1.keys & h2.keys # find words that appear in both texts
        n = Float(uniq_words.size)
        return 0 if n == 0

        sum1, sum2, sum1_sq, sum2_sq, p_sum = 0,0,0,0,0
      
        uniq_words.each do |word|
          sum1 += h1[word]
          sum2 += h2[word]
          sum1_sq += h1[word] ** 2
          sum2_sq += h2[word] ** 2
          p_sum += h1[word] * h2[word]
        end
        num = p_sum-((sum1 * sum2)/n) 
        den = Math.sqrt((sum1_sq - (sum1 ** 2)/n) * (sum2_sq - (sum2 ** 2)/n))
        return 0 if den == 0
        num / den
      end
      
      def coefficient(str1, str2)
        return 0 unless str1 && str2
        h1, h2 = [str1, str2].collect { |s| filter_freqs(freq_count(filter_words(s)))  }
        pearson(h1, h2)
      end
      
    end
  end
end