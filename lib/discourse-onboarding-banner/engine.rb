# frozen_string_literal: true

module DiscourseOnboardingBanner
  PLUGIN_NAME = "discourse-onboarding-banner"

  class Engine < ::Rails::Engine
    engine_name DiscourseOnboardingBanner::PLUGIN_NAME
    isolate_namespace DiscourseOnboardingBanner

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::DiscourseOnboardingBanner::Engine, at: "/discourse-onboarding-banner"
      end
    end
  end
end
