# #with in facets collides with #with in flexmock... only include certain 
# parts (facets?) of facets.
require 'facets/integer/factorial'

module SimilarityEngine
  
  module ArrayExtension
    # from facets/ruby.rb - will be in Ruby 1.9
    def combination(k=2)
      if block_given?
        s = to_a
        n = s.size
        return unless (1..n) === k
        idx = (0...k).to_a
        loop do
          yield s.values_at(*idx)
          i = k - 1
          i -= 1 while idx[i] == n - k + i
          break if i < 0
          idx[i] += 1
          (i + 1 ... k).each {|j| idx[j] = idx[i] + j - i}
        end
      else
        to_enum(:combination, k)
      end
    end
  end
  
  class Index
    attr_reader :klass, :tracker
    
    # Construct an Index instance. 
    #
    # Example: 
    #
    #   SimilarityIndex.new(User)
    #
    def initialize(klass, tracker)
      @klass = klass
      @tracker = tracker
    end
    
    # Computes and updates the similarity index for the two klass instances
    # given. 
    #  
    # Example: 
    #
    #   index = Index.new(User)
    #   index.update_similarity_coefficient(user1, user2)  # => nil
    #    
    def update_similarity_coefficient(inst1, inst2)
      coeff = klass.similarity_for(inst1, inst2)
      
      update_coefficient inst1, inst2, coeff
      
      nil
    end
    
    # Updates a single index for the two klass instances given. 
    #
    def update_coefficient(inst1, inst2, coeff)
      similarity_coefficient = (lookup(inst1, inst2) || SimilarityCoefficient.new)
      ids = [inst1.id, inst2.id]
      
      similarity_coefficient.attributes = {
        :model_klass => klass.to_s,
        :id_lo => ids.min, :id_hi => ids.max, 
        :coeff => coeff
      }
      
      similarity_coefficient.save!
    end
    
    # Searches the current index for an entry concerning the two objects
    # given. 
    #
    def lookup(inst1, inst2)
      ids = [inst1.id, inst2.id]
      coeff = SimilarityCoefficient.find(
        :first, 
        :conditions => {
          :model_klass => klass.to_s,
          :id_lo => ids.min, :id_hi => ids.max
        }
      )
      
      coeff
    end

    def build
      # find all instances
      instances = klass.find(:all)

      # Compute how much work there is and tell the tracker
      num_instances = instances.size
      num_pairs = num_instances.factorial / 2.factorial / (num_instances-2).factorial
      tracker.before_computation(num_pairs)

      # Extend the instances array with #combination from facets (collide with
      # rails)
      instances.extend ArrayExtension
      
      # for each unique set of 2 users
      instances.combination(2).each do |user1, user2|
        # Notify tracker
        tracker.compute_for user1, user2

        # Compute similarity
        update_similarity_coefficient user1, user2
      end
      
      # We're done
      tracker.after_computation
      
      nil
    end
  end
  
  # Implement a subclass to this class if you want to do progress tracking. 
  # Pass an instance of your subclass to the #build_similarity_index method.
  # 
  class ProgressTracker
    def before_computation(pair_count); end
    def after_computation; end
    def compute_for(user1, user2); end
  end
end