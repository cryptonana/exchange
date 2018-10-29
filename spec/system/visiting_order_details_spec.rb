require 'rails_helper'

RSpec.describe 'visit order details', type: :system do
  let(:partner_id) { 'partner1' }
  let(:user_id) { 'user1' }
  let(:state) { Order::PENDING }
  let(:created_at) { 2.days.ago }
  let!(:order) do
    Fabricate(
      :order,
      seller_id: partner_id,
      seller_type: 'partner',
      buyer_id: user_id,
      buyer_type: 'user',
      created_at: created_at,
      updated_at: 1.day.ago,
      shipping_total_cents: 100_00,
      commission_fee_cents: 50_00,
      commission_rate: 0.10,
      seller_total_cents: 50_00,
      buyer_total_cents: 100_00,
      items_total_cents: 0,
      state: state,
      state_reason: state == Order::CANCELED ? 'seller_lapsed' : nil
    )
  end

  it 'renders order overview page' do
    allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
    visit '/admin'
  end

  it 'is able to switch to All Orders tab, where it shows an order', js: true do
    order.save

    allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
    visit '/admin'

    row_selector = 'td.col.col-code'

    expect(page).to_not have_selector(row_selector)

    tab_selector = 'li.scope.all'
    within tab_selector do
      click_link 'All'
    end

    expect(page).to have_selector(row_selector)
  end

  it 'renders order details page', js: true do
    order.save

    allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
    visit '/admin'

    row_selector = 'td.col.col-code'

    expect(page).to_not have_selector(row_selector)

    tab_selector = 'li.scope.all'
    within tab_selector do
      click_link 'All'
    end

    expect(page).to have_selector(row_selector)

    within row_selector do
      click_link order.code
    end
  end
end
