# frozen_string_literal: true

class DiscourseOnboardingBannerConstraint
  def matches?(_request)
    SiteSetting.discourse_onboarding_banner_enabled
  end
end
