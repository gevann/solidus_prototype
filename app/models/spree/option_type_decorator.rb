module Spree
  module Prototypes
    module OptionType
      extend ActiveSupport::Concern

      included do
        has_many :option_type_prototypes
        has_many :prototypes, through: :option_type_prototypes
      end
    end
  end
end

Spree::OptionType.include Spree::Prototypes::OptionType
