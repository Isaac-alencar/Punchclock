# frozen_string_literal: true

include ActiveAdmin::AllocationChartHelper

ActiveAdmin.register_page 'Allocation Chart' do
  menu label: proc { I18n.t('allocation_chart') }, priority: 11

  content title: I18n.t('allocation_chart') do
    panel I18n.t('allocation_chart') do
      allocations = AllocationsAndUnalocatedUsersQuery.new(Allocation).call
      table_for allocations, id: 'allocations_chart' do
        column(I18n.t('name')) do |allocation|
          link_to allocation.user.first_and_last_name, admin_user_path(allocation.user)
        end
        column(I18n.t('client'), :project)
        column(I18n.t('allocated_until'), class: 'allocated-column') do |allocation|
          build_allocation_status_cell(allocation)
        end
        column(I18n.t('backend_level')) { |allocation| decorated_user(allocation).backend_level }
        column(I18n.t('frontend_level')) { |allocation| decorated_user(allocation).frontend_level }
        column(I18n.t('english_evaluation')) do |allocation|
          decorated_user(allocation).english_level
        end
        column(I18n.t('skills'), class: 'allocated-column__last') do |allocation|
          raw(skills_tags(allocation.user))
        end
        column(:allocated_until_data) do |allocation|
          allocation.end_at ? allocation.end_at.to_time.to_i : 'Not allocated'
        end
      end
    end
  end
end

def decorated_user(allocation)
  UserDecorator.decorate(allocation.user)
end

def build_allocation_status_cell(last_allocation)
  allocation_status = allocation_status_for(last_allocation: last_allocation)

  column_cell_base(
    content: allocation_status_content(
      last_allocation: last_allocation,
      allocation_status: allocation_status
    ),
    allocation_status: allocation_status,
    last_allocation: last_allocation
  )
end

def allocation_status_content(last_allocation:, allocation_status:)
  return I18n.l(last_allocation.end_at, format: :default) if last_allocation.end_at

  unallocated?(allocation_status) ? I18n.t('not_allocated') : I18n.t('allocated')
end

def unallocated?(allocation_status)
  allocation_status == Status::NOT_ALLOCATED
end

def column_cell_base(content:, allocation_status:, last_allocation:)
  div class: "allocated-column__status  allocated-column__status--#{allocation_status}" do
    if allocation_status == Status::NOT_ALLOCATED
      content
    else
      link_to content, admin_allocation_path(last_allocation)
    end
  end
end
