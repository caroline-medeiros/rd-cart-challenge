class CartsController < ApplicationController
  before_action :set_cart

  def show
    render_cart
  end

  def add_item
    product = Product.find_by(id: params[:product_id])
    return render_error("Product not found", :not_found) unless product

    quantity = params[:quantity].to_i
    return render_error("Quantity must be greater than 0", :unprocessable_entity) if quantity <= 0

    if @cart.add_product(product, quantity)
      render_cart
    else
      render_error("Could not add item", :unprocessable_entity)
    end
  end

  def remove_item
    if @cart.remove_product(params[:product_id])
      render_cart
    else
      render_error("Product not found in cart", :not_found)
    end
  end

  private

  def set_cart
    @cart = find_cart || create_cart
  end

  def find_cart
    Cart.find_by(id: params[:cart_id]) || Cart.find_by(id: session[:cart_id])
  end

  def create_cart
    Cart.create!(total_price: 0.0, last_interaction_at: Time.current).tap do |cart|
      session[:cart_id] = cart.id
    end
  end

  def render_cart
    render json: cart_payload(@cart), status: :ok
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end

  def cart_payload(cart)
    {
      id: cart.id,
      products: format_products(cart),
      total_price: cart.total_price.to_f
    }
  end

  def format_products(cart)
    cart.cart_items.includes(:product).map do |item|
      {
        id: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unit_price: item.unit_price.to_f,
        total_price: item.total_price.to_f
      }
    end
  end
end