# frozen_string_literal: true

# name: DiscourseOnboardingBanner
# about: Display a dismissable banner during onboarding
# version: 0.1
# authors: awesomerobot and Jamie Wilson
# url:https://github.com/discourse/discourse-onboarding-banner

register_asset 'stylesheets/common/discourse-onboarding-banner.scss'

enabled_site_setting :discourse_onboarding_banner_enabled

PLUGIN_NAME ||= 'DiscourseOnboardingBanner'

load File.expand_path('lib/discourse-onboarding-banner/engine.rb', __dir__)

after_initialize do
  # https://github.com/discourse/discourse/blob/main/lib/plugin/instance.rb
end
