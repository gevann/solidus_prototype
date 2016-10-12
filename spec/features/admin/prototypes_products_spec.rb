# encoding: utf-8
require 'spec_helper'

describe "Products", type: :feature do
  context "as admin user" do
    stub_authorization!

    before(:each) do
      visit spree.admin_path
    end

    def build_option_type_with_values(name, values)
      ot = FactoryGirl.create(:option_type, name: name)
      values.each do |val|
        ot.option_values.create(name: val.downcase, presentation: val)
      end
      ot
    end

    context "creating a new product from a prototype" do
      def build_option_type_with_values(name, values)
        ot = FactoryGirl.create(:option_type, name: name)
        values.each do |val|
          ot.option_values.create(name: val.downcase, presentation: val)
        end
        ot
      end

      let(:product_attributes) do
        # FactoryGirl.attributes_for is un-deprecated!
        #   https://github.com/thoughtbot/factory_girl/issues/274#issuecomment-3592054
        FactoryGirl.attributes_for(:simple_product)
      end

      let(:prototype) do
        size = build_option_type_with_values("size", %w(Small Medium Large))
        FactoryGirl.create(:prototype, name: "Size", option_types: [size])
      end

      let(:option_values_hash) do
        hash = {}
        prototype.option_types.each do |i|
          hash[i.id.to_s] = i.option_value_ids
        end
        hash
      end

      before(:each) do
        @option_type_prototype = prototype
        @property_prototype = create(:prototype, name: "Random")
        @shipping_category = create(:shipping_category)
        click_nav "Products"
        click_link "admin_new_product"
        within('#new_product') do
          expect(page).to have_content("SKU")
        end
      end

      it "should allow an admin to create a new product and variants from a prototype", js: true do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        fill_in "product_available_on", with: "2012/01/24"
        select "Size", from: "Prototype"
        check "Large"
        select @shipping_category.name, from: "product_shipping_category_id"
        click_button "Create"
        expect(page).to have_content("successfully created!")
        expect(Spree::Product.last.variants.length).to eq(1)
      end

      it "should not display variants when prototype does not contain option types", js: true do
        select "Random", from: "Prototype"

        fill_in "product_name", with: "Baseball Cap"

        expect(page).not_to have_content("Variants")
      end

      it "should keep option values selected if validation fails", js: true do
        fill_in "product_name", with: "Baseball Cap"
        fill_in "product_sku", with: "B100"
        fill_in "product_price", with: "100"
        select "Size", from: "Prototype"
        check "Large"
        click_button "Create"
        expect(page).to have_content("Shipping category can't be blank")
        expect(field_labeled("Size")).to be_checked
        expect(field_labeled("Large")).to be_checked
        expect(field_labeled("Small")).not_to be_checked
      end
    end

    context 'updating a product', js: true do
      let(:product) { create(:product) }

      let(:prototype) do
        size = build_option_type_with_values("size", %w(Small Medium Large))
        FactoryGirl.create(:prototype, name: "Size", option_types: [size])
      end

      before(:each) do
        @option_type_prototype = prototype
        @property_prototype = create(:prototype, name: "Random")
      end

      it 'should add option_types when selecting a prototype' do
        visit spree.admin_product_path(product)
        click_link 'Product Properties'
        expect(page).to have_content("Select From Prototype")
        click_link "Select From Prototype"

        row = find('#prototypes tr', text: 'Size')
        row.click_link 'Select'

        # The following is unfortunate.
        # It is tough to distinguish between the different fields, so we assert
        # that there are two rows (ensuring one has been added) and then
        # inspect the first one.
        expect(page).to have_css('#product_properties .product_property', count: 2)
        within('#product_properties .product_property:nth-child(1)') do
          expect(find('input[type=text]', match: :first).value).to eq('baseball_cap_color')
        end
      end
    end
  end

  context 'with only product permissions' do
    before do
      allow_any_instance_of(Spree::Admin::BaseController).to receive(:spree_current_user).and_return(nil)
    end

    custom_authorization! do |_user|
      can [:admin, :update, :index, :read], Spree::Product
    end
    let!(:product) { create(:product) }

    it "should only display accessible links on index" do
      visit spree.admin_products_path
      expect(page).not_to have_link('Prototypes')
    end
  end
end
