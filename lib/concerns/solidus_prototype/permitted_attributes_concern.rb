module SolidusPrototype
  module PermittedAttributesConcern
    extend ActiveSupport::Concern

    included do
      self.product_attributes << :prototype_id
    end

    module ClassMethods
      def product_attributes
        @@product_attributes
      end
    end
  end
end
