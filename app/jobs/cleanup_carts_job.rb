class CleanupCartsJob
  include Sidekiq::Job

  def perform
    abandoned_carts = Cart.where('last_interaction_at < ?', 3.hours.ago)

    Cart.where('last_interaction_at < ?', 7.days.ago).destroy_all

  end
end