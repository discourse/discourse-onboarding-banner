# frozen_string_literal: true

# name: discourse-onboarding-banner
# about: Display a dismissable banner during onboarding
# version: 0.1
# authors: awesomerobot and Jamie Wilson
# url: https://github.com/discourse/discourse-onboarding-banner
# transpile_js: true

register_asset 'stylesheets/common/discourse-onboarding-banner.scss'

enabled_site_setting :discourse_onboarding_banner_enabled

PLUGIN_NAME = 'discourse-onboarding-banner'
CUSTOM_FIELD_NAME = 'show_onboarding_banner'

load File.expand_path('lib/discourse-onboarding-banner/engine.rb', __dir__)

after_initialize do
  # https://github.com/discourse/discourse/blob/main/lib/plugin/instance.rb

  User.register_custom_field_type(CUSTOM_FIELD_NAME, :boolean)
  DiscoursePluginRegistry.serialized_current_user_fields << CUSTOM_FIELD_NAME
  add_to_class(:user, CUSTOM_FIELD_NAME.to_sym) do
    return false unless SiteSetting.discourse_onboarding_banner_enabled

    topic_id = SiteSetting.discourse_onboarding_banner_topic_id
    return false unless topic_id.positive?

    topic = Topic.find_by_id(topic_id)
    return false unless topic
    return false unless guardian.can_see?(topic)

    custom_fields['onboarding_banner_dismissed_topic_id'].to_i != topic_id
  end
  add_to_serializer(:current_user, :show_onboarding_banner, true) do
    object.send(CUSTOM_FIELD_NAME)
  end
end
