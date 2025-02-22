# frozen_string_literal: true

class EducationExperience < ApplicationRecord
  belongs_to :user

  validates_presence_of :institution, :course, :start_date

  validates_comparison_of :start_date,
                          message: :greater_than_current,
                          less_than: ->(_) { Date.current },
                          allow_nil: true

  validates_comparison_of :end_date,
                          message: :less_than_start_date,
                          greater_than: ->(education_experience) { education_experience.start_date },
                          allow_nil: true
end
