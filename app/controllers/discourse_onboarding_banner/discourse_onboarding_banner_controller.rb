# frozen_string_literal: true

module DiscourseOnboardingBanner
  class DiscourseOnboardingBannerController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    def index
      return render json: success_json unless current_user.show_onboarding_banner

      topic = Topic.find(SiteSetting.discourse_onboarding_banner_topic_id)

      render json: {
               topic_id: SiteSetting.discourse_onboarding_banner_topic_id,
               cooked: topic.first_post.cooked,
             }
    end

    def dismiss
      topic_id = SiteSetting.discourse_onboarding_banner_topic_id
      raise Discourse::NotFound unless topic_id&.positive? && topic_id == params[:topic_id].to_i

      current_user.custom_fields["onboarding_banner_dismissed_topic_id"] = topic_id
      current_user.save_custom_fields

      render json: success_json
    end
  end
end
