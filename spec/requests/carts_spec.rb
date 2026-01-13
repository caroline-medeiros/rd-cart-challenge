require 'rails_helper'

RSpec.describe "/cart", type: :request do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, price: 10.0) }

  describe "POST /cart" do
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context "when adding the same product again" do
      it "updates the existing item quantity" do
        post "/cart", params: { product_id: product.id, quantity: 1, cart_id: cart.id }, as: :json

        expect(response).to have_http_status(:ok)
        expect(cart_item.reload.quantity).to eq(2)
      end
    end
  end

  describe "GET /cart" do
    before do
      CartItem.create(cart: cart, product: product, quantity: 2)
      cart.update_total_and_interaction!
    end

    it "returns the cart with correct total and items" do
      get "/cart", params: { cart_id: cart.id }

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(cart.id)
      expect(json_response["total_price"].to_f).to eq(20.0)
      expect(json_response["products"].first["name"]).to eq(product.name)
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:item_to_remove) { CartItem.create(cart: cart, product: product, quantity: 1) }

    it "removes the item from the cart" do
      expect {
        delete "/cart/#{product.id}", params: { cart_id: cart.id }, as: :json
      }.to change(CartItem, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it "returns an error if the product is not in the cart" do
      delete "/cart/999", params: { cart_id: cart.id }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end