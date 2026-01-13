class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    mark_abandoned_carts
    remove_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    Cart.where('last_interaction_at < ?', 3.hours.ago).where(abandoned: [false, nil]).update_all(abandoned: true)
  end

  def remove_old_abandoned_carts
    Cart.where('last_interaction_at < ?', 7.days.ago).where(abandoned: true).destroy_all
  end
end