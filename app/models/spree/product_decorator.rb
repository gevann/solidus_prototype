module Spree
  module Prototypes
    module ProductDecorator

      def self.included(base)
        base.after_create :add_associations_from_prototype
      end

      # Overrides the prototype_id setter in order to ensure it is cast to an
      # integer.
      #
      # @param value [#to_i] the intended new value
      # @!attribute [rw] prototype_id
      #   @return [Fixnum]
      attr_reader :prototype_id
      def prototype_id=(value)
        @prototype_id = value.to_i
      end

      private

      def add_associations_from_prototype
        if prototype_id && prototype = Spree::Prototype.find_by(id: prototype_id)
          prototype.properties.each do |property|
            product_properties.create(property: property)
          end
          self.option_types = prototype.option_types
          self.taxons = prototype.taxons
        end
      end

    end
  end
end

Spree::Product.include Spree::Prototypes::ProductDecorator
