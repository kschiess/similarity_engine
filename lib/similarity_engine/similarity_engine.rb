
module SimilarityEngine  
  module ActiveRecordExtension
    def self.included(base)
      # Anybody tell me why include is private but extend isn't?
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
      
      base.class_inheritable_hash :similarity_indices
      base.similarity_indices = {}
    end
    
    module InstanceMethods
      # Finds +n+ similar objects to this one.
      #
      def find_similar(n, options={})
        searcher = Search.new(self)
        searcher.similar(n, options)
      end
    end
    
    module ClassMethods
      
      # Defines a similarity index for this model. 
      #
      def has_similarity_index(name, options = {})
        similarity_indices[name] = {
          :computation    => options[:method], 
          :weight         => (options[:weight] || 1), 
          :extract_field  => options[:extract_field]
        }
      end

      # Compute similarity by using index index_name.
      #
      # Example: 
      #
      #   User.similarity_for( user1, user2 ) # => 0.2 
      #
      def similarity_for(inst1, inst2)
        coefficient = 0
        weights = 0
        
        similarity_indices.each do |name, index|
          similarity_computation  = index[:computation]
          weight                  = index[:weight]
          
          # Extract fields if specified
          compare_values = [inst1, inst2]
          if field_name=index[:extract_field]
            compare_values = compare_values.collect { |inst| inst.send(field_name) }
          end

          # Compute similarity
          coefficient += (similarity_computation.call(*compare_values) || 0)
          weights     += weight
        end
        
        if weights == 0
          0
        else
          coefficient / Float(weights)
        end
      end
      
      # Retrieves similarity index by name. 
      #
      def similarity_index(name)
        similarity_indices[name]
      end
      
      # Allows iteration over all defined indices
      #
      def each_similarity_index
        similarity_indices.each do |name, attributes|
          yield name
        end
      end
      
      # Builds the similarity index. 
      #
      def build_similarity_index(tracker=nil)
        index = Index.new(self, tracker || ProgressTracker.new)
        index.build
      end
    end
  end
end