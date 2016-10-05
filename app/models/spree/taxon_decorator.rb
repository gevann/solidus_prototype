module Spree
  module Prototypes
    module Taxon
      extend ActiveSupport::Concern

      included do
        has_many :prototype_taxons, dependent: :destroy
        has_many :prototypes, through: :prototype_taxons
      end
    end
  end
end

Spree::Taxon.include Spree::Prototypes::Taxon
