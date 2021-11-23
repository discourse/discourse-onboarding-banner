# frozen_string_literal: true

require_dependency 'discourse_onboarding_banner_constraint'

DiscourseOnboardingBanner::Engine.routes.draw do
  get '/content' => 'discourse_onboarding_banner#index', constraints: DiscourseOnboardingBannerConstraint.new
  put '/dismiss' => 'discourse_onboarding_banner#dismiss', constraints: DiscourseOnboardingBannerConstraint.new
end
