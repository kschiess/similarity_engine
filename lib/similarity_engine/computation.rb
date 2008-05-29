
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
    
    # Pearson coefficient for str1 and str2. Pearson correlation compares 
    # word frequency in both tests. It varies from -1 (most dissimilar) to 
    # +1 (most similar) with 0 as a neutral value. 
    #
    class Pearson < Computation
      attr_reader :lower, :higher
      
      # Construct a computation that calculates the pearson correlation. 
      # +lower_cutoff+ and +higher_cutoff+ determine how much word frequency
      # data is thrown away before starting computation. 
      #
      #     |-------<XXXXXXXXXXXXXXXXXX>----------------| 
      #             ^ lower ^ included ^ higher         ^ max frequency
      #
      def initialize(lower_cutoff=0.1, higher_cutoff=0.9)
       @lower = lower_cutoff
       @higher = higher_cutoff 
      end

      # Splits the individual words in +str+ into an array. 
      #
      def tokenize(str)
        str.downcase.gsub(/\W/, ' ').split
      end
      
      # Filters a word frequency hash. Cutoff points can be configured in 
      # percent of the maximum frequency that was seen in the data by 
      # using the constructor arguments of the Pearson class. 
      #
      def filter_freqs(frequencies)
        filtered_frequencies = {}
        max_frequency = frequencies.values.max
        frequencies.each do |word, count|
          if (count >= lower * max_frequency) && (count <= higher * max_frequency)
            filtered_frequencies[word] = count 
          end
        end
        filtered_frequencies
      end
      
      # Given an array of words, counts the frequency of occurrence of each 
      # word and returns a hash mapping words to frequencies. 
      #
      def freq_count(arr)
        arr.inject(Hash.new(0)) { |freqs, word| freqs[word] += 1; freqs }
      end
      
      # Calculate the pearson correlation for two word frequency hashes. 
      #
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
      
      # Entry point for the engine. 
      #
      def coefficient(str1, str2)
        return 0 unless str1 && str2
        h1, h2 = [str1, str2].collect { |s| 
          filter_freqs(
            freq_count(
              tokenize(s)))  
        }
        pearson(h1, h2)
      end
      
    end
  end
end