require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let!(:recent_cart) { Cart.create!(total_price: 0, last_interaction_at: 1.hour.ago, abandoned: false) }
    let!(:abandoned_cart) { Cart.create!(total_price: 0, last_interaction_at: 4.hours.ago, abandoned: false) }
    let!(:very_old_cart) { Cart.create!(total_price: 0, last_interaction_at: 8.days.ago, abandoned: false) }

    it 'marks carts with more than 3 hours of inactivity as abandoned' do
      expect {
        MarkCartAsAbandonedJob.new.perform
      }.to change { abandoned_cart.reload.abandoned }.from(false).to(true)
    end

    it 'removes carts with more than 7 days of inactivity' do
      MarkCartAsAbandonedJob.new.perform
      expect(Cart.exists?(very_old_cart.id)).to be_falsey
    end

    it 'does not alter recently active carts' do
      MarkCartAsAbandonedJob.new.perform

      recent_cart.reload
      expect(recent_cart.abandoned).to be_falsey
      expect(Cart.exists?(recent_cart.id)).to be_truthy
    end
  end
end