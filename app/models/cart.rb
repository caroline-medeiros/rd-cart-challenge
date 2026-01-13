class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }


  def mark_as_abandoned
    update!(abandoned: true)
  end

  def remove_if_abandoned
    destroy if abandoned?
  end

  def add_product(product, quantity)
    item = cart_items.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + quantity

    if item.save
      update_total_and_interaction!
      true
    else
      false
    end
  end

  def remove_product(product_id)
    item = cart_items.find_by(product_id: product_id)
    if item
      item.destroy
      update_total_and_interaction!
      true
    else
      false
    end
  end

  def update_total_and_interaction!
    total = cart_items.includes(:product).sum { |item| item.quantity * item.product.price }
    update!(total_price: total, last_interaction_at: Time.current)
  end
end