# frozen_string_literal: true

module DiscourseOnboardingBanner
  class DiscourseOnboardingBannerController < ::ApplicationController
    requires_plugin DiscourseOnboardingBanner

    before_action :ensure_logged_in

    def index
      raise Discourse::NotFound unless SiteSetting.discourse_onboarding_banner_enabled

      topic_id = SiteSetting.discourse_onboarding_banner_topic_id

      topic = Topic.find(topic_id)
      guardian.ensure_can_see!(topic)
      raise Discourse::NotFound unless topic

      dismissed = current_user.custom_fields['onboarding_banner_dismissed_topic_id'].to_i == topic_id

      render json: { topic_id: SiteSetting.discourse_onboarding_banner_topic_id,
                     cooked: topic.first_post.cooked,
                     dismissed: dismissed }
    end

    def dismiss
      topic_id = SiteSetting.discourse_onboarding_banner_topic_id
      raise Discourse::NotFound unless topic_id&.positive? && topic_id == params[:topic_id].to_i

      current_user.custom_fields['onboarding_banner_dismissed_topic_id'] = topic_id
      current_user.save_custom_fields

      head :ok
    end
  end
end
