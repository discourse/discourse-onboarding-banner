# frozen_string_literal: true

require "rails_helper"

describe DiscourseOnboardingBanner::DiscourseOnboardingBannerController do
  context "when logged out" do
    it "returns error getting content" do
      get "/discourse-onboarding-banner/content.json"
      expect(response.status).to eq(404)
    end

    it "returns error dismissing content" do
      put "/discourse-onboarding-banner/dismiss.json"
      expect(response.status).to eq(404)
    end
  end

  context "when logged in" do
    fab!(:user)

    before { sign_in(user) }

    context "when plugin is disabled" do
      before { SiteSetting.discourse_onboarding_banner_enabled = false }

      it "returns error when getting content" do
        get "/discourse-onboarding-banner/content.json"
        expect(response.status).to eq(404)
      end

      it "returns error dismissing content" do
        put "/discourse-onboarding-banner/dismiss.json"
        expect(response.status).to eq(404)
      end
    end

    context "when plugin is enabled" do
      before { SiteSetting.discourse_onboarding_banner_enabled = true }

      context "without setting a topic_id" do
        it "returns error when getting content" do
          get "/discourse-onboarding-banner/content.json"

          json = response.parsed_body
          expect(json["topic_id"]).to eq(nil)
        end

        it "returns error dismissing content" do
          put "/discourse-onboarding-banner/dismiss.json"
          expect(response.status).to eq(404)
        end
      end

      context "after setting a topic_id" do
        fab!(:lounge) { Fabricate(:category, name: "VIP") }
        fab!(:topic) { Fabricate(:topic, category: lounge) }
        fab!(:post) { Fabricate(:post, topic: topic, raw: "My onboarding content") }

        before { SiteSetting.discourse_onboarding_banner_topic_id = topic.id }

        it "returns content" do
          get "/discourse-onboarding-banner/content.json"
          expect(response.status).to eq(200)

          json = response.parsed_body
          expect(json["topic_id"]).to eq(topic.id)
          expect(json["cooked"]).to include("My onboarding content")
        end

        it "stores topic dismissal" do
          put "/discourse-onboarding-banner/dismiss.json", params: { topic_id: topic.id }
          expect(response.status).to eq(200)

          expect(user.custom_fields).to eq(
            { "onboarding_banner_dismissed_topic_id" => topic.id.to_s },
          )

          get "/discourse-onboarding-banner/content.json"

          json = response.parsed_body
          expect(json["topic_id"]).to eq(nil)
        end
      end

      context "when setting an invalid topic_id" do
        it "returns an empty topic_id if topic_id is nil" do
          SiteSetting.discourse_onboarding_banner_topic_id = nil

          get "/discourse-onboarding-banner/content.json"

          json = response.parsed_body
          expect(json["topic_id"]).to eq(nil)
        end

        it "returns an empty topic_id if topic_id is invalid" do
          SiteSetting.discourse_onboarding_banner_topic_id = 99_999_999

          get "/discourse-onboarding-banner/content.json"

          json = response.parsed_body
          expect(json["topic_id"]).to eq(nil)
        end
      end
    end
  end
end
